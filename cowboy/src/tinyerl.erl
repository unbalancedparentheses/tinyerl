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
    tinyerl_sup:start_link().

%% @private
stop(_State) ->
    dets:close(urls),
    ok.
