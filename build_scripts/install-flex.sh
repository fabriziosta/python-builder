#!/bin/bash
# Top-level build script called from Dockerfile

# Stop at any error, show all commands
set -exuo pipefail

# Get script directory
MY_DIR=$(dirname "${BASH_SOURCE[0]}")

# Get build utilities
# shellcheck source-path=SCRIPTDIR
source "${MY_DIR}/build_utils.sh"

# Install flex from source. UBI public repos (baseos/appstream) do not ship
# flex; CRB may list it only with a subscription. PostgreSQL 17+ configure
# in build-libpq.sh requires flex on PATH (release tarballs no longer ship
# pre-generated lexer output).
check_var "${FLEX_ROOT}"
check_var "${FLEX_HASH}"
check_var "${FLEX_DOWNLOAD_URL}"
fetch_source "${FLEX_ROOT}.tar.gz" "${FLEX_DOWNLOAD_URL}"
check_sha256sum "${FLEX_ROOT}.tar.gz" "${FLEX_HASH}"
tar -zxf "${FLEX_ROOT}.tar.gz"
pushd "${FLEX_ROOT}"
DESTDIR=/manylinux-rootfs do_standard_install
popd
rm -rf "${FLEX_ROOT}" "${FLEX_ROOT}.tar.gz"

# Strip what we can
strip_ /manylinux-rootfs

# Install
cp -rlf /manylinux-rootfs/* /

# Remove temporary rootfs
rm -rf /manylinux-rootfs

hash -r
flex --version
