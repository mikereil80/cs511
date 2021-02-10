-module(ss).
-compile(export_all).


start () ->
    S = spawn(?MODULE ,server ,[]),
    [ spawn(?MODULE,client,[S]) || _ <- lists:seq(1,100000)].

client(S) -> %% 
    S!{start ,self()}, 
    S!{add,"h",self()}, 
    S!{add,"e",self()}, 
    S!{add,"l",self()}, 
    S!{add,"l",self()}, 
    S!{add,"o",self()}, 
    S!{done,self()}, 
    receive
	{S,Str} ->
	    io:format("Done: ~p~s~n",[self(),Str])
    end.

server() -> 
    complete.
