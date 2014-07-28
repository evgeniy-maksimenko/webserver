%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 18. июл 2014 15:03
%%%-------------------------------------------------------------------
-module(auth_success_handler).
-behaviour(cowboy_http_handler).
-author("jeka").

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
  AccessToken = c_application:getCookie(<<"access_token">>,Req),
  erlydtl:compile_file("theme/classic/views/layouts/index.dtl", index_tpl),
  {ok, Body} = index_tpl:render([{content, "Вы успешно авторизировались! Ваш token "++binary_to_list(AccessToken)}]),
  {ok, Req5} = cowboy_req:reply(200, [], Body, Req),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.