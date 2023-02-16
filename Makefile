
build-push: build push

build:
	docker compose build

push:
	docker compose push

run:
	docker compose run controller

infra-plan:
	terraform -chdir=infra plan

infra-apply:
	terraform -chdir=infra apply
