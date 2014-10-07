%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 04. сен 2014 14:49
%%%-------------------------------------------------------------------
-module(api_response_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

-record(aic_ets, {
  name  = aic_ets,
  id    = <<"id">>,
  start = 0,
  count = 1,
  filename = "aic.ets"
}).

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

-export([from_ets_to_file/2]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->

  AI = #aic_ets{},
  ID =
    case filelib:is_file(AI#aic_ets.filename) of
      true ->
        {ok, Tab} = ets:file2tab(AI#aic_ets.filename),
        [{_ID, AUTO_INC}] = ets:lookup(Tab, AI#aic_ets.id),
        CT = from_ets_to_file(Tab, AUTO_INC + AI#aic_ets.count),
        CT;
      false ->
        ets:new(AI#aic_ets.name, [named_table]),
        CF = from_ets_to_file(AI#aic_ets.name, AI#aic_ets.start),
        CF
    end,

  %Получаем тело запроса
  {ok, PostAttrs, Req2} = cowboy_req:body_qs(Req),
  [{Attrs, true}] = PostAttrs,
  %Отрезаем не нужные данные и загоняем в таблицу

  BODY = proplists:delete(<<"sys">>, jsx:decode(Attrs)),

  BodyDateTime = lists:merge(
    BODY,
    [
      {<<"id">>,integer_to_binary(ID)},
      {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")}
    ]
  ),

  TreatmentList = ets:tab2list(treatments),
  lists:foreach(fun(ListIn)->
    {Pid, _} = ListIn,
    Pid ! {json, jsx:encode(BodyDateTime)} end, TreatmentList),

  emongo:insert(model, "treatment",
    BodyDateTime
  ),
  %Отправляем ответ 200
  {ok, Req5} = cowboy_req:reply(200, [{<<"content-type">>, <<"json/application; charset=utf-8">>}],
    [<<"{\"status\":\"ok\"}">>], Req2),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.

from_ets_to_file(Tab, Count) ->
  AI = #aic_ets{},
  ets:insert(Tab, {AI#aic_ets.id, Count}),
  ets:tab2file(Tab, AI#aic_ets.filename),
  ets:delete(Tab),
  Count.

