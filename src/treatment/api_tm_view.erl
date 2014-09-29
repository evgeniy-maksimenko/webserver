%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 26. сен 2014 17:52
%%%-------------------------------------------------------------------
-module(api_tm_view).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").


%% API
-export([
  init/3,
  handle/2,
  terminate/3,
  deletekey/1,
  find/3,
  reading_the_req_body/1,
  httpPost/4,
  view/2,
  rating/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

terminate(_Reason, _Req, _State) ->
  ok.

handle(Req, State) ->
  {Code, Data} =
    try
      FindAll = reading_the_req_body(Req),
      case is_list(FindAll) orelse jsx:is_json(FindAll) of
        true ->
          {200, FindAll};
        false ->
          {403, <<"Forbidden">>}
      end
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,
  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}
  ], jsx:encode(Data), Req),
  {ok, Req2, State}.

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  find(AllBindings, IsDefined, Req);
httpPost(<<"view">>, _IsDefined, AllBindings, Req) ->
  view(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"rating">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  rating(proplists:get_value(<<"id">>, AllBindings), PostAttrs, Req1).

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