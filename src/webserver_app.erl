-module(webserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/assets/[...]", cowboy_static, {dir, "assets/"}},
      {"/authorize/", auth_handler,[]},
      {"/auth_success", auth_success_handler,[]},
      {"/", base_handler, []},
      {'_', error404_handler, []}
    ]}
  ]),
  Port = 8008,
  {ok, _} = cowboy:start_http(http_listener, 100,
    [{port, Port}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  webserver_sup:start_link().

stop(_State) ->
    ok.
