-module(erly_handler).
-export([handle/2, handle_event/3]).

-include_lib("elli/include/elli.hrl").
-behaviour(elli_handler).

handle(Req, _Args) ->
    %% Delegate to our handler function
    handle(Req#req.method, elli_request:raw_path(Req), Req).

handle('POST', <<"/", Url/binary>>, _Req) ->
    Random = ktn_random:generate(),
    RandomBinary = erlang:list_to_binary(Random),
    dets:insert(urls,
                {RandomBinary, Url}),

    RandomUrl = <<"http://localhost:3000/", RandomBinary/binary>>,
    {201, [{<<"Location">>, RandomUrl}], RandomUrl};

handle('GET', <<"/", RandomUrl/binary>>, _Req) ->
    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            {302, [{<<"Location">>, Url}], <<"">>};
        _ ->
            {404, [], <<"Not Found">>}
    end;

handle(_, _, _Req) ->
    {405, [], <<"Method Not Allowed">>}.

handle_event(_Event, _Data, _Args) ->
    ok.
