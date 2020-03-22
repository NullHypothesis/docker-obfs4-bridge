# This will be put in .env file
IMAGE=phwinter/obfs4-bridge
# This will be removed with testing or multiarch-testing(soon) pull request
VERSION=0.4.2.7-1

.PHONY: tag_latest
tag_latest:
	@[ "${VERSION}" ] || ( echo "Env var VERSION is not set."; exit 1 )

	docker tag $(IMAGE):amd64-$(VERSION) $(IMAGE):amd64-latest
	docker tag $(IMAGE):arm64-$(VERSION) $(IMAGE):arm64-latest
	docker tag $(IMAGE):arm-$(VERSION) $(IMAGE):arm-latest

.PHONY: release
release: tag_latest
	@[ "${VERSION}" ] || ( echo "Env var VERSION is not set."; exit 1 )

	docker push $(IMAGE):amd64-$(VERSION)
	docker push $(IMAGE):arm64-$(VERSION)
	docker push $(IMAGE):arm-$(VERSION)

	docker push $(IMAGE):amd64-latest
	docker push $(IMAGE):arm64-latest
	docker push $(IMAGE):arm-latest

	docker manifest create $(IMAGE):latest \
		$(IMAGE):amd64-latest \
		$(IMAGE):arm64-latest \
		$(IMAGE):arm-latest

	docker manifest push --purge $(IMAGE):latest

.PHONY: build
build:
	@[ "${VERSION}" ] || ( echo "Env var VERSION is not set."; exit 1 )

	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

	cat Dockerfile.amd64 Dockerfile.common > Dockerfile
	docker build -t $(IMAGE):amd64-$(VERSION) .

	cat Dockerfile.arm64 Dockerfile.common > Dockerfile
	docker build -t $(IMAGE):arm64-$(VERSION) .

	cat Dockerfile.arm Dockerfile.common > Dockerfile
	docker build -t $(IMAGE):arm-$(VERSION) .

.PHONY: deploy
deploy:
	@[ "${OR_PORT}" ] || ( echo "Env var OR_PORT is not set."; exit 1 )
	@[ "${PT_PORT}" ] || ( echo "Env var PT_PORT is not set."; exit 1 )
	@[ "${EMAIL}" ] || ( echo "Env var EMAIL is not set."; exit 1 )
	@docker run \
		--detach \
		--env "OR_PORT=$(OR_PORT)" \
		--env "PT_PORT=$(PT_PORT)" \
		--env "EMAIL=$(EMAIL)" \
		--publish "$(OR_PORT)":"$(OR_PORT)" \
		--publish "$(PT_PORT)":"$(PT_PORT)" \
		--restart unless-stopped \
		--volume tor-datadir-$(OR_PORT)-$(PT_PORT):/var/lib/tor \
		$(IMAGE):latest
	@echo "Make sure that port $(OR_PORT) and $(PT_PORT) are forwarded in your firewall."
