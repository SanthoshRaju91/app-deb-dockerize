#!/usr/bin/env bash
set -eu

project_name=""
project_version=""
components_to_install=()
dependencies=""

export EMAIL="tech-dssg@mail.rakuten.com"
export DEBFULLNAME="Rakuten DSSG"

die() {
	echo "error: $@"
	exit 1
}

install_cmake_components() {
	for i in $components_to_install; do
		DESTDIR=install/ cmake -DCOMPONENT=$i -P $(pwd)/../cmake_install.cmake
	done
}

run_dh_make() {
	dh_make --yes --packagename "${project_name}_${project_version}" --packageclass s --email "${DEBFULLNAME} <${EMAIL}>" --createorig
}

update_copyright() {
	echo "$1" > debian/copyright
}

append_dependencies() {
	local deps="$1"
	if [ -n "$deps" -a -n "$deps" ]; then
		initial_depends="$(cat debian/control | grep Depends | tail -n 1)"
		sed -i "s|^Depends.*$|${initial_depends},${deps}|g" debian/control
	fi
}

append_files() {
	for i in install/*; do
		local path_1="$(basename $i)"
		for j in "install/${path_1}"/*; do
			echo "install/${path_1}/$(basename $j) /${path_1}" >> "debian/install"
		done
	done
}

build_pkg() {
	debuild -us -uc -b -rfakeroot
}

print_info() {
	echo -e "\n\n::: Package informations"
	dpkg-deb -I ${project_name}_${project_version}*.deb
	echo -e "\n\n::: Package files"
	dpkg-deb -c ${project_name}_${project_version}*.deb
}

while getopts "n:v:" opt; do
	case "$opt" in
	n) project_name="${OPTARG}"
		;;
	v) project_version="${OPTARG}"
		;;
	d) dependencies="${OPTARG}"
		;;
	esac
done

shift $((OPTIND-1))
components_to_install="$@"

[ -z "${project_name}" ] && die "invalid empty project name (-n)"
[ -z "${project_version}" ] && die "invalid empty project version (-v)"
[ -z "${components_to_install}" ] && die "invalid empty components to install"

work_dir="${project_name}-${project_version}"
rm -rf "${work_dir}"
mkdir -p "${work_dir}"

pushd "${work_dir}"

install_cmake_components
run_dh_make
update_copyright "Rakuten ACP 2018"
append_dependencies "${dependencies}"
append_files
build_pkg
popd

print_info
