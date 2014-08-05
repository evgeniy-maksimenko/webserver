-module(webserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
% -export([connect_to_mysql/0]).
%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  % connect_to_mysql(),
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/assets/[...]", cowboy_static, {dir, "assets/"}},
      {"/authorize/", auth_handler, []},
      {"/auth_success", auth_success_handler, []},

      {"/order", order_handler, []},
      {"/order/edit/:id", order_edit_handler, []},
      {"/order/answer", order_answer_handler, []},
      %%================================================================================================================
      {"/api/test", api_test_handler, []},
      {"/api/get_all_orders", api_get_all_orders_handler, []},
      {"/api/get_order_info", api_get_order_info_handler, []},
      {"/api/get_order_file", api_get_order_file_handler, []},
      {"/api/set_order_work", api_set_order_work_handler, []},
      {"/api/close_order", api_close_order_handler, []},
      %%================================================================================================================
      {"/[...]", cowboy_static, {file, "priv/index.html"}},
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

%% ===================================================================
%% Подключение конфига к бд mysql
%% ===================================================================
% connect_to_mysql() ->
%     {ok, [Val|_]} = application:get_env(emysql, pools),
%     {PoolName, Params} = Val,
%     emysql:add_pool(PoolName, Params).


