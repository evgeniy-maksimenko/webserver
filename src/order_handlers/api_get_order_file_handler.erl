%%%-------------------------------------------------------------------
%%% @author jeka
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. июл 2014 22:01
%%%-------------------------------------------------------------------
-module(api_get_order_file_handler).
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
  {[ {<<"oid">> , Oid} , {<<"fileName">> , FileName}, {<<"sc_oid">> , ScOid}| _], _} = cowboy_req:qs_vals(Req),
  Newfile = re:replace(FileName, " ", "_", [global, {return, list}]),
  Result = orders_module:getOrderFile(Req, Oid, Newfile, ScOid),
  { ok, {Status, Header, Body}} = Result,

  [_,_,_,_,_,_,_,_,_,Filename|_] = Header,

  {ok, Req3} = cowboy_req:reply(200, [
    {<<"content-type">>, <<"application/octet-stream">>},
    Filename
  ], [Body], Req),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.