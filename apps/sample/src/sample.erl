-module(sample).
-behaviour(supervisor).
-behaviour(application).
-export([init/1, start/2, stop/1, main/1]).
-compile(export_all).

-define(CHILD(Id, Mod, Type, Args), {Id, {Mod, start_link, Args},
                                     permanent, 5000, Type, [Mod]}).


main(A)    -> mad_repl:sh(A).
start(_,_) -> supervisor:start_link({local,sample},sample,[]).
stop(_)    -> ok.
init([])   -> case cowboy:start_http(http,3,port(),env()) of
                   {ok, _}   -> ok;
                   {error,_} -> halt(abort,[]) end,
	      kvs:join(),
	      io:format("~nJOIN~n"),
	      sup().

sup()    -> { ok, { { one_for_one, 5, 100 }, [ ?CHILD(antiipspam, antiipspam, worker, []), ?CHILD(feizhai_reaper_sup, feizhai_reaper_sup, supervisor, []) ] } }.
env()    -> [ { env, [ { dispatch, points() } ] } ].
static() ->   { dir, "apps/sample/priv/static", mime() }.
n2o()    ->   { dir, "deps/n2o/priv",           mime() }.
materialize() -> {dir, "apps/sample/priv/materialize", mime()}.
mime()   -> [ { mimetypes, cow_mimetypes, all   } ].
port()   -> [ { port, wf:config(n2o,port,8001)  } ].
points() -> cowboy_router:compile([{'_', [
              { "/static/[...]", n2o_static, static() },
              { "/n2o/[...]",    n2o_static, n2o()    },
	      { "/materialize/[...]", n2o_static, materialize()},
              { "/ws/[...]",     n2o_stream, []       },
              { '_',             n2o_cowboy, []       }]}]).

log_modules() -> [n2o_client,n2o_nitrogen,n2o_stream,wf_convert, new_achieve, feizhai_reaper, gglmp,index].
