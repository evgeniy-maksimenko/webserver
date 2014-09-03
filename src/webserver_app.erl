-module(webserver_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([connect_db_mongoDB/0]).
-export([constructor/0]).

%% ===================================================================
%% Конфигурация БД
%% ===================================================================
-define(POOL, model).
-define(HOST, "localhost").
-define(DB,   "consultancy").
-define(PORT, 27017).
-define(SIZE, 1).

start(_StartType, _StartArgs) ->
  constructor(),
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/assets/[...]", cowboy_static, {dir, "assets/"}},
      {"/authorize/",   auth_handler, []},
      {"/auth_success", auth_success_handler, []},

      {"/order",          order_handler, []},
      {"/order/edit/:id", order_edit_handler, []},
      {"/order/answer",   order_answer_handler, []},
      %%================================================================================================================
      {"/api/find_one_record",  api_find_one_record,  []},
      {"/api/find_all_records", api_find_all_records, []},
      %%================================================================================================================
      {"/api/find_all_history", api_find_all_history, []},
      {"/api/test", api_test_handler, []},

      {"/api/get_all_orders", api_get_all_orders_handler, []},
      {"/api/get_order_info", api_get_order_info_handler, []},
      {"/api/get_order_file", api_get_order_file_handler, []},
      {"/api/set_order_work", api_set_order_work_handler, []},
      {"/api/get_user_contacts", api_get_user_contacts_handler, []},
      {"/api/post_workaround", api_post_workaround_handler, []},

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

constructor() ->
  connect_db_mongoDB(),
  ok.

%% ===================================================================
%% Подключение конфига к бд mysql
%% ===================================================================
% connect_to_mysql() ->
%     {ok, [Val|_]} = application:get_env(emysql, pools),
%     {PoolName, Params} = Val,
%     emysql:add_pool(PoolName, Params).

%% ===================================================================
%% Добавление пула
%% ===================================================================
connect_db_mongoDB() ->
  emongo:add_pool(?POOL, ?HOST, ?PORT, ?DB, ?SIZE).


