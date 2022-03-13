PACKAGE_NAME = libnginx-mod-http-modsecurity

# The Debian package version. Every time NGINX_MODSECURITY_REF
# or NGINX_VERSION changes, you must bump this number.
#
# When bumping this number, you MUST also:
# - reset PACKAGE_REVISION.
# - edit spec/control and add a changelog entry there with
#   `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as version number.
PACKAGE_VERSION = 1.0.2-2

# The version of ModSecurity-nginx you want to package. This must
# correspond to a specific tag in the ModSecurity-nginx Git repository:
# https://github.com/SpiderLabs/ModSecurity-nginx.
#
# If you change this number, then you MUST bump PACKAGE_VERSION.
NGINX_MODSECURITY_REF = 1.0.2

# The Nginx version that you want to compile ModSecurity-nginx against.
# This must be the exact same version as the one installable via the
# Ubuntu APT repository. You can use https://packages.ubuntu.com/
# to find out which version that is.
#
# If you change this number, then:
# - you MUST bump PACKAGE_VERSION.
# - you MUST synchronize the corresponding numbers in spec/control.
NGINX_VERSION = 1.18.0

# If you've updated the package, but without updating NGINX_MODSECURITY_REF
# or NGINX_VERSION (that is, you did not update PACKAGE_VERSION),
# then you must bump this number.
#
# Only modify the number before the `~` part. Don't touch the text after
# the `~` part. For example, if you want to bump `1~focal1` then
# change it to `2~focal1`.
#
# Also, be sure to edit spec/control and add a changelog entry there
# with `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as version number.
PACKAGE_REVISION = 1~focal1

DPKG_BUILDPACKAGE_ARGS =

.PHONY: all source-package binary-package dev clean

all: binary-package

binary-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb

source-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc

dev: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cp -dpR spec $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION) && eatmydata dpkg-buildpackage -b -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)

clean:
	rm -rf *.tar.gz *.xz *.dsc *.buildinfo *.changes *.deb *.ddeb *.upload $(PACKAGE_NAME)-*


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e $(PACKAGE_NAME)-$(PACKAGE_VERSION) || tar xzf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cp -dpR spec $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION) && eatmydata dpkg-buildpackage -S -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION) && eatmydata dpkg-buildpackage -b -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz: ModSecurity-nginx-$(NGINX_MODSECURITY_REF).tar.gz nginx-$(NGINX_VERSION).tar.gz
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)
	mkdir $(PACKAGE_NAME)-$(PACKAGE_VERSION)
	mkdir $(PACKAGE_NAME)-$(PACKAGE_VERSION)/nginx

	tar -C $(PACKAGE_NAME)-$(PACKAGE_VERSION) --strip-components 1 \
		-xzf ModSecurity-nginx-$(NGINX_MODSECURITY_REF).tar.gz
	tar -C $(PACKAGE_NAME)-$(PACKAGE_VERSION)/nginx --strip-components 1 \
		-xzf nginx-$(NGINX_VERSION).tar.gz

	find $(PACKAGE_NAME)-$(PACKAGE_VERSION) -print0 | xargs -0 touch -d '2022-03-13 00:00:00 UTC'
	tar -c $(PACKAGE_NAME)-$(PACKAGE_VERSION) | xz -zT 0 - > $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	@echo Written $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz

ModSecurity-nginx-$(NGINX_MODSECURITY_REF).tar.gz:
	wget --output-document=ModSecurity-nginx-$(NGINX_MODSECURITY_REF).tar.gz \
		https://github.com/SpiderLabs/ModSecurity-nginx/archive/v$(NGINX_MODSECURITY_REF).tar.gz

nginx-$(NGINX_VERSION).tar.gz:
	wget https://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz
