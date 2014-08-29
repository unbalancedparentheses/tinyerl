PROJECT = tinyerl

DEPS = leptus jiffy katana sync
dep_leptus = git https://github.com/jfacorro/leptus jfacorro.replace.makefile
dep_katana = git git@github.com:unbalancedparentheses/erlang-katana.git
dep_sync = git https://github.com/rustyio/sync.git master

include erlang.mk

RUN := erl -pa ebin -pa deps/*/ebin -smp enable -s sync ${ERL_ARGS}
NODE ?= ${PROJECT}

shell: app
	if [ -n "${NODE}" ]; then ${RUN} -name ${NODE}@`hostname` -s tinyerl; \
	else ${RUN} -s tinyerl; \
	fi
