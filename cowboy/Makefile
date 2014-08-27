PROJECT = tinyerl

DEPS = cowboy jiffy katana sync
dep_cowboy = git git@github.com:ninenines/cowboy.git
dep_katana = git git@github.com:unbalancedparentheses/erlang-katana.git
dep_sync = git https://github.com/rustyio/sync.git master

include erlang.mk

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s sync -boot start_sasl ${ERL_ARGS}
NODE ?= ${PROJECT}

shell: app
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname` -s tinyerl; \
	else ${RUN} -s tinyerl; \
	fi
