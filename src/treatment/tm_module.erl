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
  remove_id_mongo/1,
  httpPost/4,
  echo/1
]).

reading_the_req_body(Req) ->
  {AllBindings, Req1} = cowboy_req:qs_vals(Req),
  Case = httpPost(proplists:get_value(<<"condition">>, AllBindings), proplists:is_defined(<<"id">>, AllBindings), AllBindings, Req1),
  Case.

httpPost(<<"open">>, IsDefined, AllBindings, Req) ->
  tms:find(proplists:get_value(<<"id">>, AllBindings), IsDefined, Req);
httpPost(<<"open_admin">>, IsDefined, AllBindings, Req) ->
  tms:find_admin(proplists:get_value(<<"id">>, AllBindings), IsDefined, Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tms:find(AllBindings, IsDefined, Req);
httpPost(<<"made">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tms:save(PostAttrs, AllBindings, Req1);
httpPost(<<"in_work">>, _IsDefined, AllBindings, Req) ->
  tms:inWork(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"static">>, _IsDefined, _AllBindings, _Req) ->
  tms:static();
httpPost(<<"rtg">>, _IsDefined, AllBindings, _Req) ->
  tms:rating_static(AllBindings);
httpPost(<<"delete">>, _IsDefined, AllBindings, Req) ->
  tms:delete(AllBindings, Req);
httpPost(<<"all">>, IsDefined, AllBindings, Req) ->
  tm:find(AllBindings, IsDefined, Req);
httpPost(<<"view">>, _IsDefined, AllBindings, Req) ->
  tm:view(proplists:get_value(<<"id">>, AllBindings), Req);
httpPost(<<"rating">>, _IsDefined, AllBindings, Req) ->
  {ok, PostAttrs, Req1} = cowboy_req:body_qs(Req),
  tm:rating(proplists:get_value(<<"id">>, AllBindings), PostAttrs, Req1).

remove_id_mongo(List) -> remove_id_mongo(List, []).
remove_id_mongo([], Acc) -> Acc;
remove_id_mongo([H | T], Acc) ->
  [_|T2] = H,
  remove_id_mongo(T, [T2 | Acc]).

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