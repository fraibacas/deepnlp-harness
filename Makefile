
DOCKER_COMPOSE           := /usr/local/bin/docker-compose
DOCKER_COMPOSE_BASE      := $(DOCKER_COMPOSE)
DC_BUILD_DEEPNLP_UI      := $(DOCKER_COMPOSE_BASE) -f docker-compose.deepnlp_ui.yml run $(DOCKER_PARAMS) deepnlp-ui-build


.PHONY: default
default: init

.PHONY: init
init: docker-compose

.PHONY: docker-compose
docker-compose: $(DOCKER_COMPOSE)

.PHONY: clean
clean: $(DOCKER_COMPOSE)