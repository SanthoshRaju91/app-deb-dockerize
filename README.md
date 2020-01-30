# app-deb-dockerize

This is one method of containerizing an application, by creating debian package of the application

Purpose of creating a debian package, is to follow the principle shipping the application as a software bundle. 

The software bundle can be installed as a software on any server running Ubuntu. Similar approach can be followed for other linux based operatings like creating an rpm package for CentOS.

Before following the below steps, make sure your local machine or the CI / Build server is the Ubuntu based and has the following libraries installed.

```
curl 
gnupg
build-essential
cmake
devscripts
dh-make 
lintian 
rsync

```

1. First step of the process is to create a debian package, to do this execute the following command.

```
cd build && cmake ../
      -DCMAKE_BUILD_TYPE="${BUILD:-debug}"
      -DCMAKE_INSTALL_BINDIR=usr/bin
      -DCMAKE_INSTALL_INCLUDEDIR=usr/include
      -DCMAKE_INSTALL_LIBDIR=usr/lib
      -DCMAKE_INSTALL_PREFIX=/
      -DVERSION="${VERSION}"

```

2. For the next command make sure you are in the build folder, or you might have to change the values of the below command

```
../distrib/debian/build-pkg.sh -n rakuma-ops -v "${VERSION}" -d "nodejs" "rakuma-ops"

```

3. Now a debian package is ready for it to be containerized.

```
PKG=$(ls build/*.deb); echo ${PKG}

docker build --rm -t "${IMAGE}" -f distrib/rakuma-ops.dockerfile . --build-arg VERSION="${VERSION}" --build-arg deb_file="${PKG}"

```

IMAGE - is a env variable pointing to the image name with version tag like `app:1.0.0`, the version will be different and atomic for each of your builds.


4. Now the Docker image is ready, you can push it to a docker registry public/private and have it deployed.

```
docker push ${IMAGE}

```
