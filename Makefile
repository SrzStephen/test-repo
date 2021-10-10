THIS_DIR := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR:= ${THIS_DIR}build

build_archive:
	rm -rf ${BUILD_DIR}
	mkdir ${BUILD_DIR}
	pipenv lock -r > ${BUILD_DIR}/requirements.txt
	mkdir ${THIS_DIR}build/.archive
	pipenv run pip install --no-deps -t  ${BUILD_DIR}/.archive -r ${BUILD_DIR}/requirements.txt
	cp -r ${THIS_DIR}src/* ${BUILD_DIR}/.archive
	pipenv run python -m zipfile -c ${BUILD_DIR}/archive.zip ${BUILD_DIR}/.archive/*
	make upload_archive

upload_archive:
	aws s3 cp ${BUILD_DIR}/archive.zip \
	"s3://${shell aws cloudformation describe-stacks --stack-name buildbucket --query "Stacks[0].Outputs[0].OutputValue"}"

deploy:
	aws cloudformation validate-template --template-body file://${THIS_DIR}cloudformation/lambdastack.yml
	echo ${THIS_DIR}cloudformation/lambdastack.yml
	aws cloudformation deploy --template-file ${THIS_DIR}cloudformation/lambdastack.yml --stack-name foo --capabilities CAPABILITY_IAM
	aws describe-stacks --stack-name foo | grep OutputKey -A 1

deploy_test:
	#aws cloudformation validate-template --template-body file://${THIS_DIR}cloudformation/lambdastack.yml
	echo ${THIS_DIR}cloudformation/lambdastack.yml
	aws cloudformation deploy --template-file ${THIS_DIR}cloudformation/lambdastack.yml --stack-name bar1 \
	--capabilities CAPABILITY_IAM --parameter-overrides ZipLocation=${BUILD_DIR}/archive.zip

deploy_build_bucket:
	aws cloudformation deploy --template-file ${THIS_DIR}cloudformation/build_s3.yml --stack-name buildbucket

validate_test:
	aws cloudformation validate-template --template-body file://${THIS_DIR}cloudformation/lambdastack.yml

update_stage:
	aws apigateway update-stage --rest-api-id 1fk5a8hnzg --stage-name echo
