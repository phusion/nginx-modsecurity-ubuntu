# Ubuntu package for ModSecurity-Nginx

This project contains the packaging specifications of [the ModSecurity Nginx module](https://github.com/SpiderLabs/ModSecurity-nginx) for Ubuntu 17.10. It packages ModSecurity-Nginx as a dynamic module.

**Table of contents:**

<!-- MarkdownTOC depth=3 autolink="true" bracket="round" -->

- [Building the package](#building-the-package)
	- [On Ubuntu 17.10](#on-ubuntu-1710)
	- [On other Linux distros, other Ubuntu versions or other OSes](#on-other-linux-distros-other-ubuntu-versions-or-other-oses)
- [Development](#development)
	- [Anatomy](#anatomy)
	- [Workflow](#workflow)
	- [Shortening the development cycle](#shortening-the-development-cycle)
	- [Upgrading libmodsecurity and Nginx](#upgrading-libmodsecurity-and-nginx)
- [Maintenance and troubleshooting](#maintenance-and-troubleshooting)
	- [When Ubuntu upgrades Nginx](#when-ubuntu-upgrades-nginx)
	- [Releasing a package update](#releasing-a-package-update)

<!-- /MarkdownTOC -->

## Building the package

You can build a package either on Ubuntu 17.10, or on any system that supports Docker Linux containers.

### On Ubuntu 17.10

 1. Install Debian package building tools: `apt install devscripts wget git`
 2. Run: `make`

If building succeeds then this will output a file `libnginx-mod-http-modsecurity_xxxx.deb`.

If building fails then that is likely because you need to have some libraries installed. Look at the error message, install libraries as appropriate, then try again.

### On other Linux distros, other Ubuntu versions or other OSes

 1. Enter our Ubuntu 17.10 build environment Docker container: `./enter-docker.sh`
 2. Inside the container, run: `make`

This will output a file `libnginx-mod-http-modsecurity_xxxx.deb`.

## Development

This section describes how you should approach making changes to the packaging specifications. Just like when building a package, you can do development either on Ubuntu 17.10, or on any system that supports Docker Linux containers.

### Anatomy

 * The `spec/` directory contains the Debian packaging specifications (that is, the files that are usually found within the `debian/` directory).
 * The `Makefile` is used to download source files and build the package. It also specifies which version of libmodsecurity and Nginx to compile against.
 * `build-docker.sh`, `enter-docker.sh` and `docker-env/` are related to the Docker-based build environment.

### Workflow

The development workflow involves the use of `make`. You do not have to use Debian packaging tools (like dpkg-buildpackage) directly. Here is how a typical workflow looks like:

 1. Make changes in the Makefile or the `spec/` directory.
 2. Run `make dev`.
 3. Check whether the resulting .deb file is satisfactory. Go back to step 1 if not.

`make dev` performs the following actions:

 * It downloads the ModSecurity-nginx, libmodsecurity and Nginx sources and bundle them together into a single Debian-packaging-style orig tarball. This is only done once.
 * It extracts the orig tarball into ModSecurity-nginx-x.x.x and copies the spec/ directory into ModSecurity-nginx/x.x.x/debian/.
 * It runs `dpkg-buildpackage` on the ModSecurity-nginx-x.x.x directory in order to build the .deb package.

### Shortening the development cycle

`dpkg-buildpackage` can take quite a while, which is very annoying when you want to changes. There are two ways to make `dpkg-buildpackage` faster and thus shorten the development cycle:

 1. By using ccache.
 2. By invoking Make with `DPKG_BUILDPACKAGE_ARGS=-nc`: `make dev DPKG_BUILDPACKAGE_ARGS=-nc`

If you are using our Docker container, then ccache is already set up for you (though the ccache directory will be wiped when you exit the container).

With regard to `DPKG_BUILDPACKAGE_ARGS=-nc`: as you may know, by default `dpkg-buildpackage` cleans existing build products during the beginning of each invocation. If you did not make any changes to the compilation instructions then this means that all the source files are being recompiled on every `dpkg-buildpackage` invocation. Even though ccache makes recompilations faster, ideally you want to avoid recompiling at all. With `-nc`, you tell `dpkg-buildpackage` not to clean existing build products.

### Upgrading libmodsecurity and Nginx

To upgrade the version of libmodsecurity and the version of Nginx that we compile against, edit the version numbers in the Makefile. Specifically, modify `LIBMODSECURITY_REF` and `NGINX_VERSION`.

If you bump `NGINX_VERSION`, then don't forget to modify the corresponding nginx-common version specification `spec/control` as well.

## Maintenance and troubleshooting

### When Ubuntu upgrades Nginx

Nginx dynamic modules are only compatible against the *exact same* Nginx version number. From time to time, Ubuntu may upgrade their Nginx package, which breaks compatibility with our ModSecurity-nginx package. When this happens, then you need to:

 1. Upgrade the Nginx version that we compile against (see "Upgrading libmodsecurity and Nginx").
 2. Release a package update (see "Releasing a package update").

### Releasing a package update

 1. Open the Makefile and either reset `PACKAGE_REVISION` to 1 or bump or by 1. See the comments for instructions.
 2. Edit spec/changelog and add a new changelog entry. You *must* do this because the Debian packaging tools extract the version number from the changelog file. The changelog entry's version number must correspond to the value of `$(PACKAGE_VERSION)-$(PACKAGE_REVISION)` as specified in the Makefile.
 3. Rebuild the package from scratch: `make clean && make`
 4. Upload the package to your favorite APT repository. For example, to upload to the Phusion PPA: `dput ppa:phusion.nl/misc *source.changes`
