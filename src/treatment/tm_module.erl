%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 30. сен 2014 16:38
%%%-------------------------------------------------------------------
-module(tm_module).
-include("../logs.hrl").
-include("../../include/config.hrl").

%% API
-export([
  reading_the_req_body/1,
  deletekey/1,
  httpPost/4,
  echo/1
]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"open">>, IsDefined, AllBindings, Req) ->
  tms:find(proplists:get_value(<<"id">>, AllBindings), IsDefined, Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tms:find(AllBindings, IsDefined, Req);
httpPost(<<"made">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tms:save(PostAttrs, AllBindings, Req1);
httpPost(<<"in_work">>, _IsDefined, AllBindings, Req) ->
  tms:inWork(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tm:find(AllBindings, IsDefined, Req);
httpPost(<<"view">>, _IsDefined, AllBindings, Req) ->
  tm:view(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"rating">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tm:rating(proplists:get_value(<<"id">>, AllBindings), PostAttrs, Req1).

deletekey(List) -> delete_key(List, []).
delete_key([], Acc) -> Acc;
delete_key([H | T], Acc) -> delete_key(T, [proplists:delete(<<"_id">>, H) | Acc]).

echo(Req) ->
  {Code, Data} =
    try
      FindAll = reading_the_req_body(Req),
      case is_list(FindAll) orelse jsx:is_json(FindAll) of
        true ->
          {200, FindAll};
        false ->
          {403, <<"Forbidden">>}
      end
    catch
      _ : Reason -> ?LOG_ERROR("TAG ~p", [Reason]),
        {400, <<"Missing echo parameters.">>}
    end,
  {Code, Data}.