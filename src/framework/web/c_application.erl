%%%-------------------------------------------------------------------
%%% @author Admin
%%% @copyright (C) 2014, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 18. июл 2014 14:55
%%%-------------------------------------------------------------------
-module(c_application).
-author("Admin").

%% API
-export([
  getCookie/2
]).

getCookie(Name,Req) ->
  {Cookie, _} = cowboy_req:cookie(Name, Req),
  Cookie.
