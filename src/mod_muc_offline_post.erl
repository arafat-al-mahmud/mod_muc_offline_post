-module(mod_hello_world).

-behaviour(gen_mod).

-export([
    start/2,
    init/2,
    stop/1,
    muc_filter_message/3
]).

-define(PROCNAME, ?MODULE).

%% Required by ?INFO_MSG macros
-include("logger.hrl").
-include_lib("ejabberd-18.12/include/ejabberd_commands.hrl").
-include_lib("xmpp-1.2.7/include/xmpp.hrl").
-include("ejabberd-18.12/include/mod_muc_room.hrl").

%% gen_mod API callbacks
-export([start/2, stop/1]).

start(_Host, _Opts) ->
    ?INFO_MSG("Hello, ejabberd world!", []),
    register(?PROCNAME,spawn(?MODULE, init, [_Host, _Opts])),
    ok.

init(_Host, _Opts) ->
    inets:start(),
    ssl:start(),
    ejabberd_hooks:add(muc_filter_message, _Host, ?MODULE, muc_filter_message, 10),
    ok.

stop(_Host) ->
    ?INFO_MSG("Bye bye, ejabberd world!", []),
    ejabberd_hooks:delete(muc_filter_message, _Host, ?MODULE, muc_filter_message, 10),
    ok.

muc_filter_message(Stanza, MUCState, FromNick) ->
    ?INFO_MSG("muc_filter_message!", []),
    Stanza.
