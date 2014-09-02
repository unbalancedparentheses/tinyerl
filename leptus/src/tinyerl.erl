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

get("/:short_url", Req, State) ->
    RandomUrl = leptus_req:param(Req, short_url),
    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            {302, [{<<"Location">>, Url}], <<"">>, State};
        _ ->
            {404, <<"Not Found">>, State}
    end.

post("/shorten", Req, State) ->
    BodyQs = leptus_req:body_qs(Req),
    case proplists:get_value(<<"url">>, BodyQs) of
        undefined ->
            {400, <<"Missing 'url' parameter.">>, State};
        Url ->
            Random = ktn_random:generate(),
            RandomBinary = erlang:list_to_binary(Random),
            dets:insert(urls, {RandomBinary, Url}),

            RandomUrl = <<"http://localhost:8080/", RandomBinary/binary>>,
            {201, [{<<"Location">>, RandomUrl}], <<"">>, State}
    end.

terminate(_Reason, _Route, _Req, _State) ->
    ok.
