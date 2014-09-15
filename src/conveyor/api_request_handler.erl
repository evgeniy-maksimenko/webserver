%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 04. сен 2014 14:46
%%%-------------------------------------------------------------------
-module(api_request_handler).
-behaviour(cowboy_http_handler).
-include("../logs.hrl").

-define(CONV_SERVER, <<"http://app-cp-api-dev.ceb.loc">>).
-define(API_LOGIN, <<"324">>).
-define(API_SECRET,<<"yRI1kJdGgX3866kbDc4s7fIiuCRn8KU375YXJVmvT8zPgGuOd4">>).

-define(ConvId, <<"725">>).

%% API
-export([
  init/3,
  handle/2,
  terminate/3
]).

init({tcp, http}, Req, _Opts) ->
  {ok, Req, undefined_state}.

handle(Req, State) ->


  Random = <<"900">>,
  NewMsg = <<"{\"key\":", Random/binary, "}">>,
  MsgStruct = <<"{\"type\":\"create\",\"obj\":\"task\",\"conv_id\":\"",?ConvId/binary, "\",\"data\":", NewMsg/binary, "}">>,
  Json = <<"{\"ops\":[", MsgStruct/binary, "]}">>,

  Time = erlang:integer_to_binary(util:unixtime()),
  Sign = util:sha1(<<Time/binary, ?API_SECRET/binary, Json/binary, ?API_SECRET/binary>>),
  Url = binary_to_list(?CONV_SERVER) ++ "/api/1/json/" ++ binary_to_list(?API_LOGIN) ++ "/" ++ binary_to_list(Time) ++ "/" ++ binary_to_list(Sign),


  Request = httpc:request(post,
    {Url,%адрес
      [{"Content-type", "application/json; charset=utf8"}],
      "application/x-www-form-urlencoded",
      Json%параметры
    }, [], []),
  ?LOG_INFO("~p~n",[Request]),
  {ok, Req2} = cowboy_req:reply(200, [], [], Req),
  {ok, Req2, State}.

terminate(_Reason, _Req, _State) ->
  ok.

