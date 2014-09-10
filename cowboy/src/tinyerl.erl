-module(tinyerl).

-export([
         start/0,
         start/2,
         stop/1
        ]).

start() ->
    application:ensure_all_started(tinyerl).

%% @private
start(_StartType, _StartArgs) ->
    dets:open_file(urls, []),
    {ok, Pid} = tinyerl_sup:start_link(),
    start_listeners(),
    {ok, Pid}.

%% @private
stop(_State) ->
    dets:close(urls),
    cowboy:stop_listener(tinyerl_http),
    ok.

start_listeners() ->
    Dispatch =
        cowboy_router:compile(
          [{'_',
            [
             {<<"/:short-url">>, tinyerl_handler, []},
             {<<"/shorten">>, tinyerl_handler, []}
            ]
           }
          ]),

    RanchOptions =
        [
         {port, 8080}
        ],
    CowboyOptions =
        [
         {env,
          [
           {dispatch, Dispatch}
          ]},
         {compress, true},
         {timeout, 12000}
        ],

    cowboy:start_http(tinyerl_http, 10, RanchOptions, CowboyOptions).
