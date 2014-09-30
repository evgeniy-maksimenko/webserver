%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 30. сен 2014 15:51
%%%-------------------------------------------------------------------
-module(tm).
-include("../logs.hrl").
-include("../../include/config.hrl").

%% API
-export([
  deletekey/1,
  find/3,
  view/2,
  rating/3
]).

find(AllBindings, false, _Req) ->
  Find = emongo:find(model, "treatment", [{<<"status">>, proplists:get_value(<<"status">>, AllBindings)}]),
  Data = deletekey(Find),
  Data.

view(Id, _Req) ->
  Find = emongo:find(model, "treatment", [{"sh_cli_id", Id}]),
  case length(Find) of
    0 ->
      <<"Forbidden">>;
    _ ->
      Data = deletekey(Find),
      Data
  end.

rating(Id, PostAttrs, _Req) ->
  List = [<<"rating">>, <<"rating_at">>],
  DataIn = emongo:find(model, "treatment", [{"sh_cli_id", Id}]),
  Data = deletekey(DataIn),
  ListRating = [{K, V} || {K, V} <- lists:merge(Data), not lists:member(K, List)],
  ResultList = lists:merge(
    ListRating,
    [
      {<<"rating_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")},
      {<<"rating">>, proplists:get_value(<<"rating">>, PostAttrs)}
    ]
  ),
  emongo:update(model, "treatment", [{<<"sh_cli_id">>, Id}], ResultList),
  <<"{\"status\":\"ok\"}">>.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

