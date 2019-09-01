DOCKER_USER := $(DOCKER_USER)
DOCKER_PASS := $(DOCKER_PASS)
IMAGE_TAG := $(IMAGE_TAG)
IMAGE := mobiledevops/android-sdk-image

release: \
	tag_image \
	dockerhub_login \
	dockerhub_push \

tag_image: build
	docker tag $(IMAGE):latest $(IMAGE):$(IMAGE_TAG)

build:
	docker build -t $(IMAGE) .

dockerhub_login:
	echo $(DOCKER_PASS) | docker login -u $(DOCKER_USER) --password-stdin

dockerhub_push:
	docker push $(IMAGE):latest \
	&& docker push "$(IMAGE):$(IMAGE_TAG)"

.PHONY: release tag_image build dockerhub_login dockerhub_push
