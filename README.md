## Ubuntu 17.10

Check whether all build dependencies are installed:

~~~
dpkg-checkbuilddeps
~~~

If not, install them. When done, proceed with building the package:

~~~bash
make
~~~

## Other Linux distros, other Ubuntu versions or other OSes

Enter our Ubuntu 17.10 build environment Docker container:

~~~
./enter-docker.sh
~~~

Inside the container:

~~~
make
~~~
