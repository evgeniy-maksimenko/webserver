%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 22. июл 2014 16:24
%%%-------------------------------------------------------------------
-module(order_edit_handler).
-behaviour(cowboy_http_handler).
-author("Evgenij.Maksimenko").

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
  erlydtl:compile_file("theme/classic/views/order/edit.dtl", edit_tpl),
  {ok, Body} = edit_tpl:render(),
  {ok, Req5} = cowboy_req:reply(200, [], Body, Req),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.