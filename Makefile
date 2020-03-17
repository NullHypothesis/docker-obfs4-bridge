IMAGE=thymbahutymba/obfs4-bridge

# The release of a new version of the image makes it the latest
.PHONY: release-version
release-version:
	@[ "$(ARCH)" ] || ( echo "Env var ARCH is not set."; exit 1 )
	@[ "$($(ARCH)_version)" ] || ( echo "Env var $($(ARCH)_version) is not set."; exit 1 )

	docker tag $(IMAGE):$(ARCH)-$($(ARCH)_version) $(IMAGE):$(ARCH)-latest
	docker push $(IMAGE):$(ARCH)-$($(ARCH)_version)
	docker push $(IMAGE):$(ARCH)-latest

.PHONY: release-manifest
release-manifest:
	docker manifest create $(IMAGE):latest \
		$(IMAGE):amd64-latest \
		$(IMAGE):arm64-latest \
		$(IMAGE):arm-latest

	docker manifest push --purge $(IMAGE):latest

.PHONY: build
build:
	@[ "$(ARCH)" ] || ( echo "Env var ARCH is not set."; exit 1 )
	@[ "$($(ARCH)_version)" ] || ( echo "Env var $(ARCH)_version is not set."; exit 1 )

	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

	cat Dockerfile.$(ARCH) Dockerfile.common > Dockerfile
	docker build -t $(IMAGE):$(ARCH)-$($(ARCH)_version) .

.PHONY: deploy
deploy:
	docker-compose up -d obfs4-bridge
	@echo "Make sure that port $(OR_PORT) and $(PT_PORT) are forwarded in your firewall."

.PHONY: install
install:
	install -d /usr/local/lib/systemd/system
	install -m 644 ./systemd/docker-obfs4-bridge.service /usr/local/lib/systemd/system
	install -m 644 ./systemd/docker-obfs4-bridge.timer /usr/local/lib/systemd/system
	install -m 744 release-new-image /usr/local/bin

	@echo -e "\nExecute systemctl enable --now docker-obfs4-bridge.timer in order to enable and start the timer"
