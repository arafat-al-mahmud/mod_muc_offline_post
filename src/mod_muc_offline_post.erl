-module(mod_muc_offline_post).

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

muc_filter_message(#message{from = From, body = Body} = Pkt,
		   #state{config = Config, jid = RoomJID} = MUCState,
		   FromNick) ->

    ?INFO_MSG("~p.", [From#jid.lserver]),

    PostUrl = gen_mod:get_module_opt(From#jid.lserver, ?MODULE, post_url, fun(S) -> iolist_to_binary(S) end, list_to_binary("")),

    LServer = RoomJID#jid.lserver,

 %   from_user = binary_to_list(From#jid.luser),
 %   room = binary_to_list(RoomJID#jid.luser),
    BodyText = binary_to_list(xmpp:get_text(Body)),

 %   dict:to_list(MUCState#state.users),

    ?INFO_MSG("~p.", [LServer]),
    ?INFO_MSG("~p.", [Pkt]),
    ?INFO_MSG("~p.", [RoomJID#jid.luser]),
    ?INFO_MSG("~p.", [From#jid.luser]),
    ?INFO_MSG("~p.", [from_user]),
    ?INFO_MSG("~p.", [BodyText]),
    ?INFO_MSG("~p.", [binary_to_list(FromNick)]),
    ?INFO_MSG("~p.", [PostUrl]),

    FinalData = string:join(["{", "\"from\":", "\"", binary_to_list(FromNick), "\",", "\"room\":", "\"", binary_to_list(RoomJID#jid.luser), "\",", "\"body\":", BodyText, "}"], ""),
    ?INFO_MSG("~p.", [FinalData]),
    Request = {atom_to_list(PostUrl), [], "application/json", FinalData},
    httpc:request(post,  Request, [], [{sync, false}]),
    %httpc:request(post,  {"https://localhost:443", [], [], "hello"}, [], []),
    %httpc:request(post, Request, [],[]),
    Pkt.
