define install
	-rm -fr /tmp/depinstall
	cd /tmp && git clone --depth 1 $(1) depinstall
	cd /tmp/depinstall && nimble install -y
	rm -fr /tmp/depinstall
endef

dep:
	$(call install,git@github.com:2nd/stringbuilder.git)

t:
	@mkdir -p bin
	@nim c --out:./bin/tests --nimcache:./bin/nimcache jsonwriter_test.nim
	@./bin/tests
