BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'
DOCKER_COMPOSE = docker-compose -f docker-compose.yml

ifdef ON_CONCOURSE
  DOCKER_COMPOSE += -f docker-compose.concourse.yml
endif

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

ifndef ON_CONCOURSE
	DOCKER_COMPOSE += -f docker-compose.development.yml
endif

DOCKER_BUILD_CMD = $(DOCKER_COMPOSE) build $(BUNDLE_FLAGS)

build: stop
ifndef ON_CONCOURSE
	$(DOCKER_BUILD_CMD)
endif

prebuild:
	$(DOCKER_BUILD_CMD)
	$(DOCKER_COMPOSE) up --no-start

serve: build
	$(DOCKER_COMPOSE) up -d app

lint: build
	$(DOCKER_COMPOSE) run --no-deps --rm app bundle exec rubocop

test: serve
	$(DOCKER_COMPOSE) run --rm app rspec
	$(MAKE) stop

stop:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

shell: serve
	docker exec -it `docker-compose ps -q app | awk 'END{print}'` ash

.PHONY: build test serve stop lint shell
