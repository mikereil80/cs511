-module(shipping).
-compile(export_all).
-include_lib("./shipping.hrl").

% Michael Reilly
% I pledge my honor that I have abided by the Stevens Honor System.
get_ship(Shipping_State, Ship_ID) ->
    case lists:keyfind(Ship_ID, #ship.id, Shipping_State#shipping_state.ships) of
        false -> error;
        Record -> Record
    end.

get_container(Shipping_State, Container_ID) ->
    case lists:keyfind(Container_ID, #container.id, Shipping_State#shipping_state.containers) of
        false -> error;
        Record -> Record
    end.

get_port(Shipping_State, Port_ID) ->
    case lists:keyfind(Port_ID, #port.id, Shipping_State#shipping_state.ports) of
        false -> error;
        Record -> Record
    end.

get_occupied_docks(Shipping_State, Port_ID) ->
    lists:filtermap(fun(Ship_Location) -> 
        {ID, Dock, Ship_ID}=Ship_Location,
            case ID of
                Port_ID -> {true, Dock};
                _ -> false
            end
        end,
    (Shipping_State)#shipping_state.ship_locations).

% helper function to get_ship_location to check if the ship actually exists
print_ship_location([]) -> error;
print_ship_location([H]) -> H.

get_ship_location(Shipping_State, Ship_ID) ->
    print_ship_location(lists:filtermap(fun(Ship_Location) ->
        {Port_ID, Dock, ID}=Ship_Location,
            case ID of
                Ship_ID -> {true, {Port_ID,Dock}};
                _ -> false
            end
        end,
    (Shipping_State)#shipping_state.ship_locations)).

% helper function to get_container_weight to check whether all the containers actually exist
weight_helper(Shipping_State, []) -> ok;
weight_helper(Shipping_State, [H|T]) ->
    case get_container(Shipping_State, H) of
        error -> error;
        _ -> weight_helper(Shipping_State, T)
    end.

get_container_weight(Shipping_State, Container_IDs) ->
    L=weight_helper(Shipping_State, Container_IDs),
    if L==error ->
        error;
    true ->
    case Container_IDs of
        [] -> 0;
        _ ->
            lists:foldl(fun(ID,Sum) ->
                Sum+(get_container(Shipping_State,ID))#container.weight 
                    end,
                0, Container_IDs)
            end
    end.

get_ship_weight(Shipping_State, Ship_ID) ->
    case get_ship(Shipping_State, Ship_ID) of
        error -> error;
        _ -> get_container_weight(Shipping_State, 
            maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory))
        end.

% helper function to load_ship to check all the containers and the ship are all at the same port
all_same_port(Shipping_State, Ship_ID, Container_IDs) ->
    {Port,Dock}=get_ship_location(Shipping_State,Ship_ID),
    Port_Inventory=maps:get(Port, Shipping_State#shipping_state.port_inventory),
    lists:foldl(fun(Container, Sublist) -> lists:member(Container,Port_Inventory) and Sublist end,
    true, Container_IDs).

% helper function to load_ship to see if the containers will fit in the ship
ship_over_capacity(Shipping_State, Ship_ID, Container_IDs) ->
    ((get_ship(Shipping_State,Ship_ID))#ship.container_cap 
        - length(maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory)) 
        - length(Container_IDs)) < 0.

load_ship(Shipping_State, Ship_ID, Container_IDs) ->
    case all_same_port(Shipping_State, Ship_ID, Container_IDs) of
        false -> error;
        true -> case ship_over_capacity(Shipping_State,Ship_ID, Container_IDs) of
            true -> error;
            false -> {Port,Dock}=get_ship_location(Shipping_State, Ship_ID),
            {ok, #shipping_state{
                                ships=Shipping_State#shipping_state.ships,
                                containers=Shipping_State#shipping_state.containers,
                                ports=Shipping_State#shipping_state.ports,
                                ship_locations=Shipping_State#shipping_state.ship_locations,
                                ship_inventory=maps:put(Ship_ID,
                                    lists:append(maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory), Container_IDs),
                                    Shipping_State#shipping_state.ship_inventory
                                ),
                                port_inventory=maps:put(Port,
                                    lists:filter(fun (List) -> not lists:member(List, Container_IDs) end, 
                                    maps:get(Port, Shipping_State#shipping_state.port_inventory)),
                                    Shipping_State#shipping_state.port_inventory)
                                }
                            }
                end
    end.

% helper function to unload_ship to check all the given containers are actually on the ship
containers_are_on_the_ship(Shipping_State, Ship_ID, Container_IDs) ->
    Ship_Inventory=maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory),
    lists:foldl(fun(Container, Sublist) -> lists:member(Container, Ship_Inventory) and Sublist end,
    true, Container_IDs).

% helper function to unload_ship to check if all the containers can fit at the port
port_over_capacity(Shipping_State, Ship_ID, Container_IDs) ->
    {Port, Dock}=get_ship_location(Shipping_State, Ship_ID),
    ((get_port(Shipping_State, Port))#port.container_cap
        - length(maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory)) 
        - length(Container_IDs)) < 0.

unload_ship(Shipping_State, Ship_ID, Container_IDs) ->
    case containers_are_on_the_ship(Shipping_State, Ship_ID, Container_IDs) of
        false -> io:format("The given containers are not all on the same ship...\n"),
            error;
        true -> case port_over_capacity(Shipping_State, Ship_ID, Container_IDs) of
            true -> error;
            false -> {Port,Dock}=get_ship_location(Shipping_State, Ship_ID),
            {ok, #shipping_state{
                                ships=Shipping_State#shipping_state.ships,
                                containers=Shipping_State#shipping_state.containers,
                                ports=Shipping_State#shipping_state.ports,
                                ship_locations=Shipping_State#shipping_state.ship_locations,
                                ship_inventory=maps:put(Ship_ID,
                                    lists:filter(fun (List) -> not lists:member(List, Container_IDs) end,
                                    maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory)),
                                    Shipping_State#shipping_state.ship_inventory
                                ),
                                port_inventory=maps:put(Port,
                                    lists:append(maps:get(Port, Shipping_State#shipping_state.port_inventory), Container_IDs), 
                                    Shipping_State#shipping_state.port_inventory)
                                }
                            }
                end
    end.

% after unload_ship because it is easier and less code to write 
% to just have it do the same call for every container on the ship 
% than to do unload_ship_all first and then have to edit it for unload_ship, 
% without actually being able to use all of it
unload_ship_all(Shipping_State, Ship_ID) ->
    unload_ship(Shipping_State, Ship_ID, maps:get(Ship_ID, Shipping_State#shipping_state.ship_inventory)).

% helper function to set_sail to change the ship_location attribute of the map.
new_location(Shipping_State, Ship_ID, {Port_ID, Dock}, Ship_Location) ->
    lists:foldr(fun({Current_Port,Current_Dock,Current_Ship}, Location) ->
                    case Current_Ship of
                        Ship_ID -> [{Port_ID, Dock, Ship_ID}|Location];
                        _ -> [{Current_Port,Current_Dock,Current_Ship}|Location]
                    end
                end,
    [], Ship_Location).

set_sail(Shipping_State, Ship_ID, {Port_ID, Dock}) ->
    Occupied_Docks=get_occupied_docks(Shipping_State, Port_ID),
    case lists:member(Dock, Occupied_Docks) of
        true -> error;
        false -> {ok, #shipping_state{
                                    ships=Shipping_State#shipping_state.ships,
                                    containers=Shipping_State#shipping_state.containers,
                                    ports=Shipping_State#shipping_state.ports,
                                    ship_locations=new_location(Shipping_State, Ship_ID, {Port_ID, Dock}, Shipping_State#shipping_state.ship_locations),
                                    ship_inventory=Shipping_State#shipping_state.ship_inventory,
                                    port_inventory=Shipping_State#shipping_state.port_inventory
                                }
                            }
    end.

%% Determines whether all of the elements of Sub_List are also elements of Target_List
%% @returns true is all elements of Sub_List are members of Target_List; false otherwise
is_sublist(Target_List, Sub_List) ->
    lists:all(fun (Elem) -> lists:member(Elem, Target_List) end, Sub_List).




%% Prints out the current shipping state in a more friendly format
print_state(Shipping_State) ->
    io:format("--Ships--~n"),
    _ = print_ships(Shipping_State#shipping_state.ships, Shipping_State#shipping_state.ship_locations, Shipping_State#shipping_state.ship_inventory, Shipping_State#shipping_state.ports),
    io:format("--Ports--~n"),
    _ = print_ports(Shipping_State#shipping_state.ports, Shipping_State#shipping_state.port_inventory).


%% helper function for print_ships
get_port_helper([], _Port_ID) -> error;
get_port_helper([ Port = #port{id = Port_ID} | _ ], Port_ID) -> Port;
get_port_helper( [_ | Other_Ports ], Port_ID) -> get_port_helper(Other_Ports, Port_ID).


print_ships(Ships, Locations, Inventory, Ports) ->
    case Ships of
        [] ->
            ok;
        [Ship | Other_Ships] ->
            {Port_ID, Dock_ID, _} = lists:keyfind(Ship#ship.id, 3, Locations),
            Port = get_port_helper(Ports, Port_ID),
            {ok, Ship_Inventory} = maps:find(Ship#ship.id, Inventory),
            io:format("Name: ~s(#~w)    Location: Port ~s, Dock ~s    Inventory: ~w~n", [Ship#ship.name, Ship#ship.id, Port#port.name, Dock_ID, Ship_Inventory]),
            print_ships(Other_Ships, Locations, Inventory, Ports)
    end.

print_containers(Containers) ->
    io:format("~w~n", [Containers]).

print_ports(Ports, Inventory) ->
    case Ports of
        [] ->
            ok;
        [Port | Other_Ports] ->
            {ok, Port_Inventory} = maps:find(Port#port.id, Inventory),
            io:format("Name: ~s(#~w)    Docks: ~w    Inventory: ~w~n", [Port#port.name, Port#port.id, Port#port.docks, Port_Inventory]),
            print_ports(Other_Ports, Inventory)
    end.
%% This functions sets up an initial state for this shipping simulation. You can add, remove, or modidfy any of this content. This is provided to you to save some time.
%% @returns {ok, shipping_state} where shipping_state is a shipping_state record with all the initial content.
shipco() ->
    Ships = [#ship{id=1,name="Santa Maria",container_cap=20},
              #ship{id=2,name="Nina",container_cap=20},
              #ship{id=3,name="Pinta",container_cap=20},
              #ship{id=4,name="SS Minnow",container_cap=20},
              #ship{id=5,name="Sir Leaks-A-Lot",container_cap=20}
             ],
    Containers = [
                  #container{id=1,weight=200},
                  #container{id=2,weight=215},
                  #container{id=3,weight=131},
                  #container{id=4,weight=62},
                  #container{id=5,weight=112},
                  #container{id=6,weight=217},
                  #container{id=7,weight=61},
                  #container{id=8,weight=99},
                  #container{id=9,weight=82},
                  #container{id=10,weight=185},
                  #container{id=11,weight=282},
                  #container{id=12,weight=312},
                  #container{id=13,weight=283},
                  #container{id=14,weight=331},
                  #container{id=15,weight=136},
                  #container{id=16,weight=200},
                  #container{id=17,weight=215},
                  #container{id=18,weight=131},
                  #container{id=19,weight=62},
                  #container{id=20,weight=112},
                  #container{id=21,weight=217},
                  #container{id=22,weight=61},
                  #container{id=23,weight=99},
                  #container{id=24,weight=82},
                  #container{id=25,weight=185},
                  #container{id=26,weight=282},
                  #container{id=27,weight=312},
                  #container{id=28,weight=283},
                  #container{id=29,weight=331},
                  #container{id=30,weight=136}
                 ],
    Ports = [
             #port{
                id=1,
                name="New York",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=2,
                name="San Francisco",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=3,
                name="Miami",
                docks=['A','B','C','D'],
                container_cap=200
               }
            ],
    %% {port, dock, ship}
    Locations = [
                 {1,'B',1},
                 {1, 'A', 3},
                 {3, 'C', 2},
                 {2, 'D', 4},
                 {2, 'B', 5}
                ],
    Ship_Inventory = #{
      1=>[14,15,9,2,6],
      2=>[1,3,4,13],
      3=>[],
      4=>[2,8,11,7],
      5=>[5,10,12]},
    Port_Inventory = #{
      1=>[16,17,18,19,20],
      2=>[21,22,23,24,25],
      3=>[26,27,28,29,30]
     },
    #shipping_state{ships = Ships, containers = Containers, ports = Ports, ship_locations = Locations, ship_inventory = Ship_Inventory, port_inventory = Port_Inventory}.
