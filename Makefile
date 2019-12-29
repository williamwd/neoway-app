.PHONY: image publish run run-docker test

# if you want to use your own registry, change "REGISTRY" value
REGISTRY       = 533649339973.dkr.ecr.us-east-1.amazonaws.com
REGISTRY_USER   = $(REGISTRY)
NAME            = neoway-app
IMAGE           = $(REGISTRY_USER)/$(NAME):$(VERSION)
IMAGE_LATEST	= $(REGISTRY)/$(NAME):latest

image: guard-VERSION ## Build image
	docker build -t $(IMAGE) .

publish: guard-VERSION ## Publish image
	docker tag $(IMAGE_LATEST) $(IMAGE)
	docker push $(IMAGE)
	docker push $(IMAGE_LATEST)

run: ## Run locally
	go run .

run-docker: guard-VERSION ## Run docker container
	docker run --rm -d --name $(NAME) -d -p 5000:5000 $(REGISTRY_USER)/$(NAME):$(VERSION)

test:
	go test -coverprofile=coverage.out ./...

guard-%:
	@ if [ "${${*}}" = ""  ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi
