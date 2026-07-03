IMAGE_TAG := $(IMAGE_TAG)
IMAGE := mobiledevops/android-sdk-image

release:
	docker buildx build --platform linux/amd64,linux/arm64 \
		-t $(IMAGE):latest -t $(IMAGE):$(IMAGE_TAG) --push .

build:
	docker build -t $(IMAGE) .

run:
	docker run -it --rm $(IMAGE) /bin/bash

.PHONY: release build run
