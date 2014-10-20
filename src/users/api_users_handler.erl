%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. окт 2014 08:55
%%%-------------------------------------------------------------------
-module(api_users_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").
-export([init/3, handle/2, terminate/3]).

-export([mongo_find_one/1, mongo_save/1, mongo_find_all/0, mongo_update/2, mongo_delete/1, mongo_get_answer/2, remove_id_mongo/1]).
-record(mongo_db, {
  table = model,
  collection = "users"
}).



-define(SUCCESS_SAVE,   <<"Данные успешно сохранены">>).
-define(SUCCESS_UPDATE, <<"Данные успешно сохранены">>).
-define(SUCCESS_DELETE, <<"Данные успешно удалены">>).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->
  {Method, AllBindings, Body, Req2} = rest_logic:request(Req),
  ImplementStatus = case Method of
    post ->
      processing(proplists:get_value(<<"condition">>, AllBindings), AllBindings, Body, Req2);
    get ->
      processing(proplists:get_value(<<"condition">>, Body), AllBindings, Body, Req2)
  end,
  {ok, Req4} = cowboy_req:reply(200, [{<<"content-type">>, <<"json/application; charset=utf-8">>}], [jsx:encode(ImplementStatus)], Req2),
  {ok, Req4, State}.

processing(<<"add_user">>, _AllBindings, Body, _Req) ->
  Name = proplists:get_value(<<"name">>, Body),
  Status = mongo_save([{<<"name">>, Name}]),
  Status;

processing(<<"all">>, _AllBindings, _Body , _Req) ->
  Status = mongo_find_all(),
  Status;

processing(<<"delete">>, AllBindings, _Body , _Req) ->
  ID = proplists:get_value(<<"id">>, AllBindings),
  mongo_delete(ID);

processing(<<"view">>, AllBindings, _Body , _Req) ->
  ID = proplists:get_value(<<"id">>, AllBindings),
  mongo_find_one([{<<"id">>, ID}]);

processing(<<"update">>, _AllBindings, Body , _Req) ->
  ID = proplists:get_value(<<"id">>, Body),
  Name = proplists:get_value(<<"name">>, Body),
  mongo_update(ID, [{<<"id">>,ID}, {<<"name">>, Name}]).

%% ======================================================================================================
%% client API для работы с монго
%% ======================================================================================================
mongo_find_one(Condition) ->
  M = #mongo_db{},
  remove_id_mongo(emongo:find(M#mongo_db.table, M#mongo_db.collection, Condition)).

mongo_find_all() ->

  M = #mongo_db{},
  remove_id_mongo(emongo:find(M#mongo_db.table, M#mongo_db.collection, [])).

mongo_update(ID, Condition) ->
  M = #mongo_db{},
  Status = emongo:update(M#mongo_db.table,  M#mongo_db.collection, [{<<"id">>, ID}], Condition),
  mongo_get_answer(Status, ?SUCCESS_UPDATE).

mongo_delete(ID) ->
  M = #mongo_db{},
  Status = emongo:delete(M#mongo_db.table,  M#mongo_db.collection, [{<<"id">>, ID}]),
  mongo_get_answer(Status, ?SUCCESS_DELETE).

mongo_save(Condition) ->
  M = #mongo_db{},
  ID = app_logic:generate_autoinc(),
  Status = emongo:insert(M#mongo_db.table, M#mongo_db.collection, lists:merge(
    Condition,
    [
      {<<"id">>, integer_to_binary(ID)}
    ]
  )),
  mongo_get_answer(Status, ?SUCCESS_SAVE).

remove_id_mongo(List) -> remove_id_mongo(List, []).
remove_id_mongo([], Acc) -> Acc;
remove_id_mongo([H | T], Acc) ->
  [_|T2] = H,
  remove_id_mongo(T, [T2 | Acc]).

mongo_get_answer(Status, Alert) ->
  case Status of
    ok ->
      [{<<"status">>, Alert}];
    _ ->
      [{<<"status">>, list_to_binary(atom_to_list(Status))}]
  end.

