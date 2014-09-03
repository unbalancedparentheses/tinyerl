-module(tinyerl_handler).

-export([
         init/3,
         handle/2,
         terminate/3]
       ).

init(_Type, Req, _Opts) ->
    {ok, Req, #{}}.

handle(Req, State) ->
    try
        case cowboy_req:method(Req) of
            {<<"POST">>, Req1} ->
                handle_post(Req1, State);
            {<<"GET">>, Req1} ->
                handle_get(Req1, State);
            _ ->
                throw(unallowed_method)
        end
    catch
        throw:Reason ->
            handle_exception(Reason, Req, State)
    end.

terminate(_Reason, _Req, _State) ->
    ok.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Private functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handle_post(Req, State) ->
    {Path, Req1} = cowboy_req:path(Req),
    throw_when(not_found, Path /= <<"/shorten">>),

    {ok, Params, Req2} = cowboy_req:body_qs(Req1),
    Url = proplists:get_value(<<"url">>, Params),
    throw_when(bad_request, Url == undefined),

    Random = ktn_random:generate(),
    RandomBinary = erlang:list_to_binary(Random),
    dets:insert(urls, {RandomBinary, Url}),

    ShortUrl = <<"http://localhost:3000/", RandomBinary/binary>>,
    Headers = [{<<"Location">>, ShortUrl}],
    {ok, Req3} = cowboy_req:reply(201, Headers, Req2),
    {ok, Req3, State}.

handle_get(Req, State) ->
    {<<"/", RandomUrl/binary>>, Req1} = cowboy_req:path(Req),
    case dets:lookup(urls, RandomUrl) of
        [{_, Url}] ->
            Headers = [{<<"Location">>, Url}],
            {ok, Req2} = cowboy_req:reply(302, Headers, Req1),
            {ok, Req2, State};
        _ ->
            throw(not_found)
    end.

%%% Error handling

handle_exception(Reason, Req, State) ->
    Code = status_code(Reason),
    {ok, Req1} = cowboy_req:reply(Code, Req),
    {ok, Req1, State}.

status_code(unallowed_method) -> 405;
status_code(bad_request) -> 400;
status_code(not_found) -> 404.

throw_when(Reason, IsThrown) ->
    case IsThrown of
        true -> throw(Reason);
        _ -> ok
    end.
