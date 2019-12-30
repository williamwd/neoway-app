.PHONY: image publish run run-docker test

# if you want to use your own registry, change "REGISTRY" value
REGISTRY       	= $(PROVISIONED_REGISTRY)
NAME            = neoway-app-registry
IMAGE           = $(REGISTRY):$(VERSION)
IMAGE_LATEST	= $(REGISTRY):latest

image: guard-VERSION ## Build image
	docker build -t $(IMAGE) .
	@echo "{\"AWSEBDockerrunVersion\": \"1\",\"Image\": {\"Name\": \"$(IMAGE_LATEST)\",\"Update\": \"true\"},\"Ports\":[{\"ContainerPort\": \"5000\"}]}" > Dockerrun.aws.json

publish: guard-VERSION ## Publish image
	docker tag $(IMAGE) $(IMAGE_LATEST)
	docker push $(IMAGE)
	docker push $(IMAGE_LATEST)

run: ## Run locally
	go run .

run-docker: guard-VERSION ## Run docker container
	docker run --rm -d --name $(NAME) -d -p 5000:5000 $(IMAGE)

test:
	go test -coverprofile=coverage.out ./...

guard-%:
	@ if [ "${${*}}" = ""  ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi
