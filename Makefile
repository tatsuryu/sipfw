MAKEFLAGS += --silent

SHELL = /bin/bash

CONF_PATH=/etc/sipfw
RC_PATH=/etc/init.d
BIN_PATH=/usr/local/sbin
LIB_PATH=/usr/local/lib


.PHONY: install remove purge lib

.DEFAULT_GOAL := install


$(CONF_PATH)/sipfw.conf:
	install -d $(CONF_PATH)
	cp -n etc/sipfw.conf $(CONF_PATH)

$(RC_PATH)/sipfw:
	install bin/sipfw $(RC_PATH)/sipfw
	install -d /etc/bash_completion.d
	install etc/sipfw-completion.bash /etc/bash_completion.d/sipfw.bash
	chmod +x $(RC_PATH)/sipfw

$(LIB_PATH)/sipfw/sipfw-common.sh:
	install -d ${LIB_PATH}/sipfw
	install lib/sipfw-common.sh ${LIB_PATH}/sipfw/sipfw-common.sh

$(BIN_PATH)/sipfw_mng:
	install bin/sipfw_mng $(BIN_PATH)/sipfw_mng
	chmod +x $(BIN_PATH)/sipfw_mng

install: $(CONF_PATH)/sipfw.conf $(RC_PATH)/sipfw $(BIN_PATH)/sipfw_mng
ifneq ($(shell id -u),0)
	$(error "Voce precisa ser root para executar esta acao")
endif
install: $(LIB_PATH)/sipfw/sipfw-common.sh

remove:
ifneq ($(shell id -u),0)
	$(error "Voce precisa ser root para executar esta acao")
endif
	rm -f $(BIN_PATH)/sipfw_mng $(RC_PATH)/sipfw
	rm -rf ${LIB_PATH}/sipfw
	rm -f /etc/bash_completion.d/sipfw.bash

purge: remove
	rm -f $(CONF_PATH)/sipfw.conf
	rmdir $(CONF_PATH)

.PHONY: tests clean_tests

BATS=tests/libs/bats/bin/bats
BATS_ASSERT=tests/libs/bats-assert/load.bash
BATS_SUPPORT=tests/libs/bats-support/load.bash

$(BATS):
	git clone https://github.com/bats-core/bats-core.git tests/libs/bats

$(BATS_ASSERT):
	git clone https://github.com/bats-core/bats-assert.git tests/libs/bats-assert

$(BATS_SUPPORT):
	git clone https://github.com/bats-core/bats-support.git tests/libs/bats-support

tests: $(BATS) $(BATS_ASSERT) $(BATS_SUPPORT)
	@echo "Iniciando Testes"
	@PATH=${PATH}:./tests/libs/bats/bin bats tests/*.bats

clean_tests:
	rm -rf tests/libs

DOCKER_ID=$(shell id -u)
DOCKER_GID=$(shell id -g)
export DOCKER_ID DOCKER_GID

.PHONY: docker compose compose-down

docker:
	docker build \
		-t tatsuryu/sipfw:latest \
		-f docker/Dockerfile \
		--build-arg UID=${DOCKER_ID} \
		--build-arg GID=${DOCKER_GID} .

compose: docker
	docker-compose -f docker/docker-compose.yaml up -d
	docker-compose -f docker/docker-compose.yaml exec sipfw bash

compose-down:
	docker-compose -f docker/docker-compose.yaml down
