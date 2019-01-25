
DOCKER_COMPOSE         := /usr/local/bin/docker-compose
DOCKER_COMPOSE_BASE    := $(DOCKER_COMPOSE)
DC_RUN_PARAMS          := --force-recreate
DC_BUILD_PARAMS        := --build --force-recreate
UI_SERVICE_NAME        := deepnlp-ui


.PHONY: default
default: run

.PHONY: run
run: $(DOCKER_COMPOSE)
	@echo "running DeepNLP UI"
	DC_DEEPNLP_UI_ACTION=run $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(DC_RUN_PARAMS) $(UI_SERVICE_NAME)

.PHONY: clean
clean: $(DOCKER_COMPOSE)
	@echo "cleaning DeepNLP UI files"
	DC_DEEPNLP_UI_ACTION=clean $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(UI_SERVICE_NAME)

.PHONY: build
build: $(DOCKER_COMPOSE)
	@echo "building DeepNLP UI image and local files"
	DC_DEEPNLP_UI_ACTION=build $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(DC_BUILD_PARAMS) $(UI_SERVICE_NAME)

$(DOCKER_COMPOSE):
	@if [ ! -w $(@) ]; then echo 'docker-compose not found. Please install it'; exit 2; else true; fi
