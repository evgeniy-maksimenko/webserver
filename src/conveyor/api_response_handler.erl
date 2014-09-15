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

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->

  %Получаем тело запроса
  {ok, PostAttrs, Req2} = cowboy_req:body_qs(Req),
  [{Attrs, true}] = PostAttrs,
  %Отрезаем не нужные данные и загоняем в таблицу

  BODY = proplists:delete(<<"sys">>, jsx:decode(Attrs)),

  case ets:lookup(treatments, ws_handler) of
    [{_, Pid}] ->
      case is_pid(Pid) of
        true ->
          Pid ! {json, jsx:encode(BODY)};
        false -> undefined
      end;
    [] -> false
  end,

  emongo:insert(model, "treatment",
    lists:merge(
      BODY,
      [
        {<<"created_at">>, erlydtl_dateformat:format(erlang:localtime(), "Y-m-d H:i:s")}
      ]
    )
  ),
  %Отправляем ответ 200
  {ok, Req5} = cowboy_req:reply(200, [{<<"content-type">>, <<"json/application; charset=utf-8">>}],
    [<<"{\"status\":\"ok\"}">>], Req2),
  {ok, Req5, State}.

terminate(_Reason, _Req, _State) ->
  ok.
