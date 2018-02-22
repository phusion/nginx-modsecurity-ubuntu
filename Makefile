PACKAGE_NAME = libnginx-mod-http-modsecurity
PACKAGE_VERSION = 1.0.0
PACKAGE_REVISION = 1
MODSECURITY_REF = 2b052b0edb38b5a7
NGINX_VERSION = 1.12.1
DPKG_BUILDPACKAGE_ARGS =

.PHONY: all source-package binary-package test clean

all: binary-package

binary-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb

source-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc

test: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cp -dpR spec ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -b -jauto $(DPKG_BUILDPACKAGE_ARGS)

clean:
	rm -rf *.tar.gz *.git *.dsc *.buildinfo *.changes *.deb


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e ModSecurity-nginx-$(PACKAGE_VERSION) || tar xzf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cp -dpR spec ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -S -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -b -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz: ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz nginx-$(NGINX_VERSION).tar.gz ModSecurity.git/HEAD
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)
	tar xzf ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz

	tar -C ModSecurity-nginx-$(PACKAGE_VERSION) -xzf nginx-$(NGINX_VERSION).tar.gz
	mv ModSecurity-nginx-$(PACKAGE_VERSION)/nginx-$(NGINX_VERSION) ModSecurity-nginx-$(PACKAGE_VERSION)/nginx

	git clone ModSecurity.git ModSecurity-nginx-$(PACKAGE_VERSION)/ModSecurity
	cd ModSecurity-nginx-$(PACKAGE_VERSION)/ModSecurity && git reset --hard $(MODSECURITY_REF)
	cd ModSecurity-nginx-$(PACKAGE_VERSION)/ModSecurity && git submodule update --init --recursive
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/ModSecurity/.git

	tar -c ModSecurity-nginx-$(PACKAGE_VERSION) | xz -zT 0 - > $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	@echo Written $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz

ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz:
	wget --output-document=ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz \
		https://github.com/SpiderLabs/ModSecurity-nginx/archive/v$(PACKAGE_VERSION).tar.gz

nginx-$(NGINX_VERSION).tar.gz:
	wget https://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz

ModSecurity.git/HEAD:
	git clone --bare --recurse-submodules https://github.com/SpiderLabs/ModSecurity.git ModSecurity.git
