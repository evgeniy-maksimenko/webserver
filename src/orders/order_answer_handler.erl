%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 16:24
%%%-------------------------------------------------------------------
-module(order_answer_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").
-author("Evgenij.Maksimenko").

-define(IS_EMPTY,0).
-define(IS_SET,1).
%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

%% Заметка, возможно проблема с кодировкой
%% Решение unicode:characters_to_binary([Body])

handle(Req, State) ->
  {ID, STATUS} =
    try
      {NewId, NewStatus} =
        case cowboy_req:qs_vals(Req) of
          {[{<<"id">>, Id}, {<<"status">>, Status}| _], _} -> {Id, Status};
          _ -> throw
        end,

      {NewId, NewStatus}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        { 0, <<"Missing echo parameters.">>}
    end,


  Is_Answered = emysql:execute(model, list_to_binary("SELECT id_solution, is_answered FROM result_response WHERE is_answered=1 AND id_solution=" ++ binary_to_list(ID))),
  {_, _, _, Ans, _} = Is_Answered,
  IsAnswerEmpty = string:len(Ans),

  {MainCode, _MainId, MainStatus} =
    if
      IsAnswerEmpty == ?IS_EMPTY ->
        emysql:execute(model, list_to_binary("INSERT INTO result_response SET id_solution=" ++ binary_to_list(ID) ++ " , is_answered=1 , status=" ++ STATUS)),
        {200, ID, <<"Спасибо за ответ">>};
      IsAnswerEmpty == ?IS_SET ->
        {400, ID, <<"Извините вы уже ответили">>}
    end,

  erlydtl:compile_file("theme/classic/views/order/messages.dtl", messages_tpl),
  {ok, Body} = messages_tpl:render([{content, MainStatus}]),
  {ok, Req5} = cowboy_req:reply(MainCode, [], Body, Req),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.