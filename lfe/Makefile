PROJECT = tinyerl

DEPS = lfe lmug jiffy katana sync barista
dep_lfe = git git://github.com/rvirding/lfe.git develop
dep_katana = git git@github.com:unbalancedparentheses/erlang-katana.git
dep_sync = git https://github.com/rustyio/sync.git master
dep_lmug = git git@github.com:lfex/lmug.git
dep_barista = git git@github.com:lfex/barista.git

include erlang.mk

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s sync -boot start_sasl ${ERL_ARGS}
NODE ?= ${PROJECT}

shell: app
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname` -s tinyerl; \
	else ${RUN} -s tinyerl; \
	fi
