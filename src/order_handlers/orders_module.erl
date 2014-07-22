%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. июл 2014 14:31
%%%-------------------------------------------------------------------
-module(orders_module).
-author("Admin").

%% API
-export([
  getAllOrders/3
]).

-define(URL,"https://itsmtest.it.loc").
-define(ALL_ORDERS,?URL++"/tech/rest/dt_workorders/list.json").

getAllOrders(Req, Status, Dest) ->
  AccessToken = c_application:getCookie(<<"access_token">>,Req),
  Response = c_http_request:get(?ALL_ORDERS++"?status="++Status++"&destinate="++Dest++"&access_token="++binary_to_list(AccessToken)),
  Body = c_http_request:response_body(Response),
  Result = list_to_binary(Body),
  AaData = proplists:get_value(<<"aaData">>,jsx:decode(Result)),
  jsx:encode(AaData).