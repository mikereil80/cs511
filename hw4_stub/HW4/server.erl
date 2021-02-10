-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

%% Michael Reilly
%% I pledge my honor that I have abided by the Stevens Honor System.

%% executes join protocol from server perspective
do_join(ChatName, ClientPID, Ref, State) ->
    case maps:is_key(ChatName, State#serv_st.chatrooms) of
		true -> ChatPID=maps:get(ChatName, State#serv_st.chatrooms),
				Nickname=maps:get(ClientPID,State#serv_st.nicks),
				ChatPID!{self(), Ref, register, ClientPID, Nickname},
				State#serv_st{
					nicks=State#serv_st.nicks,
					registrations=maps:put(ChatName,
						(maps:get(ChatName,State#serv_st.registrations))++[ClientPID],
						State#serv_st.registrations),
					chatrooms=State#serv_st.chatrooms
				};
		false -> ChatPID=spawn(chatroom,start_chatroom,[ChatName]),
				Nickname=maps:get(ClientPID,State#serv_st.nicks),
				ChatPID!{self(), Ref, register, ClientPID, Nickname},
				State#serv_st{
					nicks=State#serv_st.nicks,
					registrations=maps:put(ChatName, [ClientPID], State#serv_st.registrations),
					chatrooms=maps:put(ChatName, ChatPID, State#serv_st.chatrooms)
				}
	end.


%% executes leave protocol from server perspective
do_leave(ChatName, ClientPID, Ref, State) ->
    ChatPID=maps:get(ChatName, State#serv_st.chatrooms),
	NewState=State#serv_st{
				nicks=State#serv_st.nicks,
				registrations=maps:update(ChatName, 
					lists:delete(ClientPID, maps:get(ChatName, State#serv_st.registrations)),
					State#serv_st.registrations),
				chatrooms=State#serv_st.chatrooms
	},
	ChatPID!{self(), Ref, unregister, ClientPID},
	ClientPID!{self(), Ref, ack_leave},
	NewState.

%% Helper function to do_new_nick which goes through the registrations of clients 
%% in the current chatroom and makes a list of all the client PIDs in the chatroom.
%% It then looks for our current client's PID in the list.
%% It then gets the PID of the chatroom to send the update message.
do_new_nick_help(State, Ref, ClientPID, NewNick, Chatrooms) ->
	case maps:get(Chatrooms, State#serv_st.registrations) of
		ClientPID_list ->
			case lists:member(ClientPID, ClientPID_list) of
				true -> case maps:get(Chatrooms, State#serv_st.chatrooms) of
							ChatPID -> ChatPID!{self(), Ref, update_nick, ClientPID, NewNick}
						end
			end
	end.

%% executes new nickname protocol from server perspective
do_new_nick(State, Ref, ClientPID, NewNick) ->
    case lists:member(NewNick, maps:values(State#serv_st.nicks)) of
		true -> ClientPID!{self(), Ref, err_nick_used},
				State;
		false -> NewState=State#serv_st{
					nicks=maps:update(ClientPID, NewNick, State#serv_st.nicks),
					registrations=State#serv_st.registrations,
					chatrooms=State#serv_st.chatrooms
				},
				lists:map(fun(X) -> do_new_nick_help(State, Ref, ClientPID, NewNick, X) end, maps:keys(State#serv_st.chatrooms)),
				ClientPID!{self(), Ref, ok_nick},
				NewState
	end.

%% Helper function to do_new_nick which goes through the registrations of clients 
%% in the current chatroom and makes a list of all the client PIDs in the chatroom.
%% It then looks for our current client's PID in the list.
%% It then gets the PID of the chatroom to unregister it from the chatroom.
do_client_quit_helper(State, Ref, ClientPID, Chatrooms) ->
	case maps:get(Chatrooms, State#serv_st.registrations) of
		ClientPID_list ->
			case lists:member(ClientPID, ClientPID_list) of
				true -> case maps:get(Chatrooms, State#serv_st.chatrooms) of
							ChatPID -> ChatPID!{self(), Ref, unregister, ClientPID}
						end
			end
	end.

%% executes client quit protocol from server perspective
do_client_quit(State, Ref, ClientPID) ->
    lists:map(fun(X) -> X == do_client_quit_helper(State, Ref, ClientPID, X) end, maps:keys(State#serv_st.chatrooms)),
	ClientPID!{self(), Ref, ack_quit},
	State#serv_st{
		nicks=maps:remove(ClientPID, State#serv_st.nicks),
		registrations=maps:map(fun(X, Y) when is_list(X) -> lists:delete(ClientPID, Y) end, State#serv_st.registrations),
		chatrooms=State#serv_st.chatrooms
	}.