-module( gg ).
-compile(export_all).

start() ->
    S = spawn(fun server/0),
    spawn(?MODULE, client, [S]).

server() ->
    RS = rand:uniform(11),
    receive
        {From, C_GUESS} ->
            case C_GUESS of
                RS -> From!{self(), gotIt};
                _ -> From!{self(), tryAgain},
                      server()
            end
    end.

client(S) ->
    RC = rand:uniform(11),
    S!{self(), RC},
    receive
        {From, S_RESPONSE} ->
            case S_RESPONSE of
                  gotIt -> ok;
                  tryAgain -> client(S)
                end
    end.

