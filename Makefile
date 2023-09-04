SHELL=/bin/bash

install:
	pip install -r requirements-dev.txt
	npm install -g aws-cdk-local aws-cdk

deploy_local:
	LAMBDA_DOCKER_FLAGS='-p 19891:19891' localstack start -d

	cdklocal bootstrap
	cdklocal deploy -v