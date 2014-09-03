%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 16. июл 2014 22:01
%%%-------------------------------------------------------------------
-module(api_get_order_file_handler).
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

%% Заметка, возможно проблема с кодировкой
%% Решение unicode:characters_to_binary([Body])

handle(Req, State) ->
  {Code, GetFileNameNew, BodyNew} =
    try
      {NewOid, NewFileName, NewScOid} =
        case cowboy_req:qs_vals(Req) of
          {[ {<<"oid">> , Oid} , {<<"fileName">> , FileName}, {<<"sc_oid">> , ScOid}| _], _} -> {Oid, FileName, ScOid};
          _ -> missing_echo_params
        end,
      FileNameWith_ = re:replace(NewFileName, " ", "_", [global, {return, list}]),
      Res = orders_module:getOrderFile(Req, NewOid, FileNameWith_, NewScOid),

      {HeaderValid, BodyValid} =
        case Res of
          {ok, {_, Header, Body}} -> {Header, Body};
          _ -> error_get_file_attrs
        end,
      GetFileName = proplists:get_value("content-disposition",HeaderValid),
      {200, GetFileName, BodyValid}
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"noname">> , <<"Missing echo parameters.">>}
    end,

  {ok, Req3} = cowboy_req:reply(Code, [
    {<<"content-type">>, <<"application/octet-stream">>},
    {<<"content-disposition">>,GetFileNameNew}
  ], [BodyNew], Req),
  {ok, Req3, State}.

terminate(_Reason, _Req, _State) ->
  ok.