# Guesses config from some gathered data
#
#

CONFIGURATION = $(shell sh ./guess-host.sh || echo unknown)
USER = $(shell whoami)

SYSTEMCFG = $(firstword $(subst :, ,$(CONFIGURATION)))
ARCHCFG = $(word 2,$(subst :, ,$(CONFIGURATION)))

ifeq (unknown,$(SYSTEMCFG))
ifndef TESTING
$(error "Unknown config, rerun with TESTING=1 to include ../config.mk")
endif
include ../config.mk
else
include ../configs/$(SYSTEMCFG)/config_$(ARCHCFG).mk
endif

ifeq (build,$(USER))
include ../docker_config.mk
else
-include ../local_config.mk
endif

