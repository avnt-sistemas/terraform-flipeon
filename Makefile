SHELL=/bin/bash

install:
	pip install -r requirements-dev.txt
	npm install -g aws-cdk-local aws-cdk

deploy_local:
	localstack start -d

	cdklocal bootstrap
	cdklocal deploy -v