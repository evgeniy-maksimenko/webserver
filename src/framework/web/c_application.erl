%%%-------------------------------------------------------------------
%%% @author Evgenij.Maksimenko
%%% @copyright (C) 2014, PrivatBank
%%% @mail evgenij.maksimenko.01@privatbank.ua
%%%
%%% Created : 18. июл 2014 14:55
%%%-------------------------------------------------------------------
-module(c_application).
-author("Evgenij.Maksimenko").

%% API
-export([
  getCookie/2
]).

getCookie(Name,Req) ->
  {Cookie, _} = cowboy_req:cookie(Name, Req),
  Cookie.
