PACKAGE_NAME = libnginx-mod-http-modsecurity

# The version of ModSecurity-nginx you want to package. This must
# correspond to a specific tag in the ModSecurity-nginx Git repository:
# https://github.com/SpiderLabs/ModSecurity-nginx.
PACKAGE_VERSION = 1.0.0

# The libmodsecurity (https://github.com/SpiderLabs/ModSecurity)
# Git commit that you want to compile ModSecurity-nginx against.
# You will probably want the latest commit on the `v3/master` branch.
LIBMODSECURITY_REF = 2b052b0edb38b5a7

# The Nginx version that you want to compile ModSecurity-nginx against.
# This must be the exact same version as the one installable via the
# Ubuntu APT repository. You can use https://packages.ubuntu.com/
# to find out which version that is.
#
# Don't forget to synchronize with the version numbers
# in spec/control.
NGINX_VERSION = 1.12.1

# If -- upon releasing a new package -- you had bumped `PACKAGE_VERSION`
# compared to the previous package, then reset this number to 1.
#
# Otherwise (e.g. you only bumped LIBMODSECURITY_REF/NGINX_VERSION, or
# you made other changes to the package), then bump this number by 1.
PACKAGE_REVISION = 1

DPKG_BUILDPACKAGE_ARGS =

.PHONY: all source-package binary-package dev clean

all: binary-package

binary-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb

source-package: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc

dev: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cp -dpR spec ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -b -jauto $(DPKG_BUILDPACKAGE_ARGS)

clean:
	rm -rf *.tar.gz *.xz *.git *.dsc *.buildinfo *.changes *.deb *.ddeb ModSecurity-nginx-*


$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc: $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	test -e ModSecurity-nginx-$(PACKAGE_VERSION) || tar xzf $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cp -dpR spec ModSecurity-nginx-$(PACKAGE_VERSION)/debian
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -S -jauto $(DPKG_BUILDPACKAGE_ARGS)

$(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).deb: $(PACKAGE_NAME)_$(PACKAGE_VERSION)-$(PACKAGE_REVISION).dsc
	cd ModSecurity-nginx-$(PACKAGE_VERSION) && dpkg-buildpackage -b -jauto $(DPKG_BUILDPACKAGE_ARGS)


$(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz: ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz nginx-$(NGINX_VERSION).tar.gz libmodsecurity.git/HEAD
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)
	tar xzf ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz

	tar -C ModSecurity-nginx-$(PACKAGE_VERSION) -xzf nginx-$(NGINX_VERSION).tar.gz
	mv ModSecurity-nginx-$(PACKAGE_VERSION)/nginx-$(NGINX_VERSION) ModSecurity-nginx-$(PACKAGE_VERSION)/nginx

	git clone libmodsecurity.git ModSecurity-nginx-$(PACKAGE_VERSION)/libmodsecurity
	cd ModSecurity-nginx-$(PACKAGE_VERSION)/libmodsecurity && git reset --hard $(LIBMODSECURITY_REF)
	cd ModSecurity-nginx-$(PACKAGE_VERSION)/libmodsecurity && git submodule update --init --recursive
	rm -rf ModSecurity-nginx-$(PACKAGE_VERSION)/libmodsecurity/.git

	tar -c ModSecurity-nginx-$(PACKAGE_VERSION) | xz -zT 0 - > $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz
	@echo Written $(PACKAGE_NAME)_$(PACKAGE_VERSION).orig.tar.xz

ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz:
	wget --output-document=ModSecurity-nginx-$(PACKAGE_VERSION).tar.gz \
		https://github.com/SpiderLabs/ModSecurity-nginx/archive/v$(PACKAGE_VERSION).tar.gz

nginx-$(NGINX_VERSION).tar.gz:
	wget https://nginx.org/download/nginx-$(NGINX_VERSION).tar.gz

libmodsecurity.git/HEAD:
	git clone --bare --recurse-submodules https://github.com/SpiderLabs/ModSecurity.git libmodsecurity.git
