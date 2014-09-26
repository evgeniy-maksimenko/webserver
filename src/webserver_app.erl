-module(webserver_app).

-behaviour(application).
-include("logs.hrl").

%% Application callbacks
-export([start/2, stop/1]).
-export([connect_db_mongoDB/0]).
-export([constructor/0]).
-export([authorization/1]).

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
  ets:new(treatments, [named_table, public, set]),
  ets:new(treatments_btns, [named_table, public, set]),
  ets:new(treatments_clocer, [named_table, public, set]),
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
      %% conveyor
      {"/api/conveyor/request", api_request_handler, []},
      {"/api/conveyor/response", api_response_handler, []},
      %%================================================================================================================
      %% treatments
      {"/api/treatments" , api_treatments, []},
      {"/websocket", ws_handler, []},
      {"/ws_btn", ws_btn_handler, []},
      {"/ws_closer", ws_closer_handler, []},
      %%================================================================================================================
      {"/[...]", cowboy_static, {file, "priv/index.html"}},
      {'_', error404_handler, []}
    ]}
  ]),
  Port = 8008,
  {ok, _} = cowboy:start_http(http_listener, 100,
    [{port, Port}],
    [
      {env, [{dispatch, Dispatch}]},
      {onrequest, fun ?MODULE:authorization/1}
    ]
  ),
  webserver_sup:start_link().

authorization(Req) ->
  {Path, Req2} = cowboy_req:path(Req),
  case Path of
    <<"/authorize">> ->
      Req2;
    _ ->
%%       auth_handler:getAuthPage(Req2)
    Req2
  end,
  Req2.

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





