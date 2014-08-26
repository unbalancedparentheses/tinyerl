PROJECT = erly

DEPS = elli jiffy sync
dep_elli = git git@github.com:knutin/elli.git
dep_jiffy = git https://github.com/davisp/jiffy.git master
dep_sync = git https://github.com/rustyio/sync.git master

include erlang.mk

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s sync -boot start_sasl ${ERL_ARGS}
NODE ?= ${PROJECT}

shell: app
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname`; \
	else ${RUN}; \
	fi
