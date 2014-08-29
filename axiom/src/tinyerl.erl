-module(tinyerl).
-behaviour(application).

-export([start/2,
         stop/1,
         start/0,
         handle/3]).

start() ->
    application:ensure_all_started(tinyerl).

start(_StartType, _StartArgs) ->
    ktn_random:start_link(),
    dets:open_file(urls, []),
    axiom:start(?MODULE).

stop(_State) ->
    dets:close(urls),
    ok.

handle(<<"POST">>, _, Req) ->
    {<<"/", Url/binary>>, _} = cowboy_req:path(Req),
    Random = ktn_random:generate(),
    RandomBinary = erlang:list_to_binary(Random),
    dets:insert(urls,
                {RandomBinary, Url}),

    RandomUrl = <<"http://localhost:7654/", RandomBinary/binary>>,
    {201, [{<<"Location">>, RandomUrl}], RandomUrl};

handle(<<"GET">>, _, Req) ->
    {<<"/", RandomUrl/binary>>, _} = cowboy_req:path(Req),

    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            {302, [{<<"Location">>, Url}], <<"">>};
        _ ->
            {404, [], <<"Not Found">>}
    end;

handle(_Method, _Path, _Req) ->
    {404, <<"nope.">>}.
