-module(erly).

-export([
         start/2,
         stop/1
        ]).

%% @private
start(_StartType, _StartArgs) ->
    start_listeners().

%% @private
stop(_State) ->
    cowboy:stop_listener(gossip_http),
    ok.

start_listeners() ->
    Dispatch =
        cowboy_router:compile(
          [{'_',
            [
             {<<"/">>, erly_handler, []}
            ]
           }
          ]),

    RanchOptions =
        [{port, 8080}],
    CowboyOptions =
        [
         {env,
          [
           {dispatch, Dispatch}
          ]},
         {compress, true},
         {timeout, 12000}
        ],

    cowboy:start_http(gossip_http, 10, RanchOptions, CowboyOptions).
