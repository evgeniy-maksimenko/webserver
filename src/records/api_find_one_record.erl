%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 18. авг 2014 21:56
%%%-------------------------------------------------------------------
-module(api_find_one_record).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->
  {RecordId, Req1} = cowboy_req:qs_val(<<"record_id">>, Req),
  {Code, Model} =
    try
      ModelRecord = emongo:find(model, "records", [{<<"record_id">>, RecordId}]),
      [Record|_] = ModelRecord,
      Result = proplists:delete(<<"_id">>, Record),
      {200, Result}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {200, <<"Запись не найдена.">>}
    end,

  {ok, Req2} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/json">>}

  ], jsx:encode(Model), Req1), %

  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.