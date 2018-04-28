PACKAGE_NAME = libnginx-mod-http-modsecurity

# The Debian package version. Every time MODSECURITY_REF, LIBMODSECURITY_REF,
# or NGINX_VERSION changes, you must bump this number.
#
# When bumping this number, you MUST also:
# - reset PACKAGE_REVISION.
# - edit spec/control and add a changelog entry there with
#   `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as version number.
PACKAGE_VERSION = 1.0.1

# The version of ModSecurity-nginx you want to package. This must
# correspond to a specific tag in the ModSecurity-nginx Git repository:
# https://github.com/SpiderLabs/ModSecurity-nginx.
#
# If you change this number, then you MUST bump PACKAGE_VERSION.
MODSECURITY_REF = 1.0.0

# The libmodsecurity (https://github.com/SpiderLabs/ModSecurity)
# Git commit that you want to compile ModSecurity-nginx against.
# You will probably want the latest commit on the `v3/master` branch.
#
# If you change this number, then you MUST bump PACKAGE_VERSION.
LIBMODSECURITY_REF = 6f92c8914a822f

# The Nginx version that you want to compile ModSecurity-nginx against.
# This must be the exact same version as the one installable via the
# Ubuntu APT repository. You can use https://packages.ubuntu.com/
# to find out which version that is.
#
# If you change this number, then:
# - you MUST bump PACKAGE_VERSION.
# - you MUST synchronize the corresponding numbers in spec/control.
NGINX_VERSION = 1.14.0

# If you've updated the package, but without updating MODSECURITY_REF,
# LIBMODSECURITY_REF or NGINX_VERSION (that is, you did not update PACKAGE_VERSION),
# then you must bump this number.
#
# Only modify the number before the `~` part. Don't touch the text after
# the `~` part. For example, if you want to bump `1~bionic1` then
# change it to `2~bionic1`.
#
# Also, be sure to edit spec/control and add a changelog entry there
# with `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as version number.
PACKAGE_REVISION = 1~bionic1

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
	rm -rf *.tar.gz *.xz *.git *.dsc *.buildinfo *.changes *.deb *.ddeb *.upload $(PACKAGE_NAME)-*


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e $(PACKAGE_NAME)-$(PACKAGE_VERSION) || tar xzf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cp -dpR spec $(PACKAGE_NAME)-$(PACKAGE_VERSION)/debian
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION) && eatmydata dpkg-buildpackage -S -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION) && eatmydata dpkg-buildpackage -b -us -uc -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz: ModSecurity-nginx-$(MODSECURITY_REF).tar.gz nginx-$(NGINX_VERSION).tar.gz libmodsecurity.git/HEAD
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)
	mkdir $(PACKAGE_NAME)-$(PACKAGE_VERSION)
	mkdir $(PACKAGE_NAME)-$(PACKAGE_VERSION)/nginx

	tar -C $(PACKAGE_NAME)-$(PACKAGE_VERSION) --strip-components 1 \
		-xzf ModSecurity-nginx-$(MODSECURITY_REF).tar.gz
	tar -C $(PACKAGE_NAME)-$(PACKAGE_VERSION)/nginx --strip-components 1 \
		-xzf nginx-$(NGINX_VERSION).tar.gz

	git clone libmodsecurity.git $(PACKAGE_NAME)-$(PACKAGE_VERSION)/libmodsecurity
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION)/libmodsecurity && git reset --hard $(LIBMODSECURITY_REF)
	cd $(PACKAGE_NAME)-$(PACKAGE_VERSION)/libmodsecurity && git submodule update --init --recursive
	rm -rf $(PACKAGE_NAME)-$(PACKAGE_VERSION)/libmodsecurity/.git

	find $(PACKAGE_NAME)-$(PACKAGE_VERSION) -print0 | xargs -0 touch -d '2018-04-28 00:00:00 UTC'
	tar -c $(PACKAGE_NAME)-$(PACKAGE_VERSION) | xz -zT 0 - > $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	@echo Written $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz

ModSecurity-nginx-$(MODSECURITY_REF).tar.gz:
	wget --output-document=ModSecurity-nginx-$(MODSECURITY_REF).tar.gz \
		https://github.com/SpiderLabs/ModSecurity-nginx/archive/v$(MODSECURITY_REF).tar.gz

nginx-$(NGINX_VERSION).tar.gz:
	wget https://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz

libmodsecurity.git/HEAD:
	git clone --bare --recurse-submodules https://github.com/SpiderLabs/ModSecurity.git libmodsecurity.git
