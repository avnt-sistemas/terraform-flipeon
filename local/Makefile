SHELL=/bin/bash

install:
	pip install -r requirements-dev.txt
	npm install -g aws-cdk-local aws-cdk

deploy_local:
	docker network create localstack
	docker-compose up -d

	cdklocal bootstrap
	cdklocal deploy -v