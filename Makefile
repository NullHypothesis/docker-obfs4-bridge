IMAGE=phwinter/obfs4-bridge

.PHONY: tag
tag:
	test -n "$(VERSION)" # $$VERSION
	docker tag $(IMAGE) $(IMAGE):$(VERSION)
	docker tag $(IMAGE) $(IMAGE):latest

.PHONY: release
release:
	test -n "$(VERSION)" # $$VERSION
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

.PHONY: build
build:
	docker build -t $(IMAGE) .

.PHONY: deploy
deploy:
	test -n "$(OR_PORT)" # $$OR_PORT
	test -n "$(PT_PORT)" # $$PT_PORT
	test -n "$(EMAIL)" # $$EMAIL

	@docker run \
		--detach \
		--env "OR_PORT=$(OR_PORT)" \
		--env "PT_PORT=$(PT_PORT)" \
		--env "EMAIL=$(EMAIL)" \
		--publish "$(OR_PORT)":"$(OR_PORT)" \
		--publish "$(PT_PORT)":"$(PT_PORT)" \
		--restart unless-stopped \
		--volume tor-vol:/var/lib/tor \
		$(IMAGE):latest
