PROJECT = erly

DEPS = elli jiffy katana sync
dep_elli = git git@github.com:knutin/elli.git
dep_jiffy = git https://github.com/davisp/jiffy.git master
dep_katana = git git@github.com:unbalancedparentheses/erlang-katana.git
dep_sync = git https://github.com/rustyio/sync.git master

include erlang.mk

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s sync -boot start_sasl ${ERL_ARGS}
NODE ?= ${PROJECT}

shell: app
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname` -s erly; \
	else ${RUN} -s erly; \
	fi
