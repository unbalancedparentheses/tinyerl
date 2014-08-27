-module(tinyerl_sup).
-behaviour(supervisor).
-export([start_link/0, init/1]).

-define(CHILD(I, Type, Args), {I, {I, start_link, Args}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    ElliOpts = [{callback, tinyerl_handler}, {port, 3000}],
    {ok, {
       {one_for_one, 5, 10},
       [
        ?CHILD(elli, worker, [ElliOpts] ),
        ?CHILD(ktn_random, worker, [])
       ]}
    }.
