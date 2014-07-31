%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. июл 2014 22:01
%%%-------------------------------------------------------------------
-module(base_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").
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


  auth_handler:getAuthPage(Req),

  erlydtl:compile_file("theme/classic/views/layouts/index.dtl", index_tpl),
  {ok, Body} = index_tpl:render([{content, "Привет МИР!"}]),
  {ok, Req5} = cowboy_req:reply(200, [], Body, Req),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.




