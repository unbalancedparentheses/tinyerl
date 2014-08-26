-module(erly_handler).
-export([handle/2, handle_event/3]).

-include_lib("elli/include/elli.hrl").
-behaviour(elli_handler).

handle(Req, _Args) ->
    %% Delegate to our handler function
    handle(Req#req.method, elli_request:raw_path(Req), Req).

handle('POST', <<"/", Url/binary>>, _Req) ->
    Random = ktn_random:generate(),
    dets:insert(urls,
                {erlang:list_to_binary(Random), Url}),
    {ok, [], Random};

handle('GET', <<"/", RandomUrl/binary>>, _Req) ->
    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            {302, [{<<"Location">>, Url}], <<"">>};
        _ ->
            {404, [], <<"Not Found">>}
    end;

handle(_, _, _Req) ->
    {404, [], <<"Not Found">>}.

handle_event(_Event, _Data, _Args) ->
    ok.
