-module(erly_handler).
-export(
   [
    init/3,
    rest_init/2,
    content_types_accepted/2,
    content_types_provided/2,
    forbidden/2,
    resource_exists/2,
    allowed_methods/2,
    handle_get/2
   ]).

allowed_methods(Req, State) ->
    {[<<"GET">>], Req, State}.

handle_get(Req, State) ->
    Body = <<"8080">>,
    {Body, Req, State}.

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_rest}.

rest_init(Req, _Opts) ->
    {ok, Req, #{}}.

content_types_accepted(Req, State) ->
   {[
      {<<"application/json">>, handle_post}
     ],
     Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, handle_get}], Req, State}.

forbidden(Req, State) ->
    {false, Req, State}.

resource_exists(Req, State) ->
    {Method, Req1} = cowboy_req:method(Req),
    {Method =/= <<"POST">>, Req1, State}.
