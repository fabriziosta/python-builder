#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

# Install GNU bison from source. UBI public repos (baseos/appstream) do not
# ship bison; CRB may list it only with a subscription. PostgreSQL configure
# in build-libpq.sh requires bison on PATH.
check_var "${BISON_ROOT}"
check_var "${BISON_HASH}"
check_var "${BISON_DOWNLOAD_URL}"
fetch_source "${BISON_ROOT}.tar.gz" "${BISON_DOWNLOAD_URL}"
check_sha256sum "${BISON_ROOT}.tar.gz" "${BISON_HASH}"
tar -zxf "${BISON_ROOT}.tar.gz"
pushd "${BISON_ROOT}"
DESTDIR=/manylinux-rootfs do_standard_install
popd
rm -rf "${BISON_ROOT}" "${BISON_ROOT}.tar.gz"

# Strip what we can
strip_ /manylinux-rootfs

# Install
cp -rlf /manylinux-rootfs/* /

# Remove temporary rootfs
rm -rf /manylinux-rootfs

hash -r
bison --version
