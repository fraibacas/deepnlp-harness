
DOCKER_COMPOSE              := /usr/local/bin/docker-compose
DOCKER_COMPOSE_BASE         := $(DOCKER_COMPOSE)
DC_RUN_PARAMS               := --force-recreate
DC_BUILD_PARAMS             := --build --force-recreate
UI_SERVICE_NAME             := deepnlp-ui
DEEPNLP_BUILD_SERVICE_NAME  := deepnlp-build
DEEPNLP_BASE_IMG            := deepnlp_base:latest
DEEPNLP_BASE_IMG_HASH       := $(shell command docker images -q ${DEEPNLP_BASE_IMG} 2> /dev/null)
DEEPNLP_IMG                 := deepnlp:latest

.PHONY: default
default: run-ui

.PHONY: run-ui
run: $(DOCKER_COMPOSE)
	@echo "running DeepNLP UI"
	DC_DEEPNLP_UI_ACTION=run $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(DC_RUN_PARAMS) $(UI_SERVICE_NAME)

.PHONY: clean-ui
clean-ui: $(DOCKER_COMPOSE)
	@echo "cleaning DeepNLP UI files"
	DC_DEEPNLP_UI_ACTION=clean $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(UI_SERVICE_NAME)

.PHONY: build-ui
build-ui: $(DOCKER_COMPOSE)
	@echo "building DeepNLP UI image and local files"
	DC_DEEPNLP_UI_ACTION=build $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up $(DC_BUILD_PARAMS) $(UI_SERVICE_NAME)

.PHONY: ansible
ansible: $(DOCKER_COMPOSE) base_image
	@echo "building DeepNLP ansible tar from the current source"
	DC_DEEPNLP_ACTION=ansible $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up ${DC_BUILD_PARAMS} $(DEEPNLP_BUILD_SERVICE_NAME)

.PHONY: ansible-prod
ansible-prod: $(DOCKER_COMPOSE) base_image
	@echo "building DeepNLP ansible tar from the current source ofuscating jars"
	DC_DEEPNLP_ACTION=ansible-prod $(DOCKER_COMPOSE_BASE) -f docker-compose.yaml up ${DC_BUILD_PARAMS} $(DEEPNLP_BUILD_SERVICE_NAME)

.PHONY: base_image
base_image: $(DOCKER_COMPOSE)
	@if [ -z $(DEEPNLP_BASE_IMG_HASH) ]; then\
		echo "building DeepNLP base image...";\
		docker build --no-cache -t ${DEEPNLP_BASE_IMG} -f Dockerfile.deepnlp_base .;\
	fi

.PHONY: deepnlp_image
deepnlp_image: $(DOCKER_COMPOSE) base_image
	@if [ -z $(ANSIBLE_TARBALL) ]; then\
		echo "Usage: make deepnlp_image ANSIBLE_TARBALL=<tarball with deepnlp binaries from artifacts folder>";\
	else\
		echo "building DeepNLP image from tarball ${ANSIBLE_TARBALL}...";\
		docker build --no-cache -t ${DEEPNLP_IMG} -f Dockerfile.deepnlp --build-arg ANSIBLE_TARBALL=${ANSIBLE_TARBALL} ./artifacts;\
	fi


$(DOCKER_COMPOSE):
	@if [ ! -w $(@) ]; then echo 'docker-compose not found. Please install it'; exit 2; else true; fi
