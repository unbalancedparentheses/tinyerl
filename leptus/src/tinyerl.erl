-module(tinyerl).
-compile({parse_transform, leptus_pt}).

-behavior(application).

%% Application callbacks
-export([
         start/0,
         start/2,
         stop/1
        ]).

%% Leptus callbacks
-export([init/3,
         terminate/4]).

%% Leptus routes
-export([get/3,
         post/3]).

start() ->
    application:ensure_all_started(tinyerl).

%% @private
start(_StartType, _StartArgs) ->
    ktn_random:start_link(),
    dets:open_file(urls, []),
    leptus:start_listener(http, [{'_', [{tinyerl, undefined}]}]).

%% @private
stop(_State) ->
    dets:close(urls),
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Leptus callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init(_Route, _Req, State) ->
    {ok, State}.

get("/:url", Req, State) ->
    io:format("GET~n"),
    <<"/", RandomUrl/binary>> = leptus_req:uri(Req),
    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            {302, [{<<"Location">>, Url}], <<"">>, State};
        _ ->
            {404, <<"Not Found">>, State}
    end.

post("/:url", Req, State) ->
    io:format("POST~n"),
    <<"/", Url/binary>> = leptus_req:uri(Req),
    Random = ktn_random:generate(),
    RandomBinary = erlang:list_to_binary(Random),
    dets:insert(urls, {RandomBinary, Url}),

    RandomUrl = <<"http://localhost:8080/", RandomBinary/binary>>,
    {201, [{<<"Location">>, RandomUrl}], <<"">>, State}.

terminate(_Reason, _Route, _Req, _State) ->
    ok.
