-module(tinyerl_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

-define(CHILD(I, Type, Args), {I, {I, start_link, Args}, permanent, 5000, Type, [I]}).

start_link() ->
    start_cowboy_listeners(),
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, {
       {one_for_one, 5, 10},
       [
        ?CHILD(ktn_random, worker, [])
       ]}
    }.

start_cowboy_listeners() ->
    Dispatch =
        cowboy_router:compile(
          [{'_',
            [
             {<<"/">>, tinyerl_handler, []}
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
