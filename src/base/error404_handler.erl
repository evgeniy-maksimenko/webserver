%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. июл 2014 22:18
%%%-------------------------------------------------------------------
-module(error404_handler).
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
  erlydtl:compile_file("theme/classic/views/layouts/404.dtl", notfound404_tpl),
  {ok, Body} = notfound404_tpl:render([{content, "Ошибка 404. Страница не найдена."}]),
  {ok, Req2} = cowboy_req:reply(200, [], Body, Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.