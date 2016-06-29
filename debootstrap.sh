#!/bin/bash
#
# The openSUSE Distribution Enabling Bootstrap script
#
# This script provides the same semantics as the Debian debootstrap scripts,
# but instead gives you an openSUSE chroot.
#
# It does so by downloading a server created rootfs tarball from the Opensuse
# Build Service.
#
# Written by Alexander Graf <agraf@suse.de>, 2016
#
# This script is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# It is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# A copy of the GNU General Public License can be downloaded from
# http://www.gnu.org/licenses/gpl.html

set -e

ARCH=$(uname -m)
VERSION="openSUSE Debootstrap 1.0"

function usage() {
    echo "XXX need to write help text"
    exit 1
}

while [ $# -gt 0 ]
do
    case $1 in
    --version)
        echo "$VERSION"
        exit 0
        ;;
    --foreign)
        # We don't run code inside the chroot, so we're safe
        ;;
    --resolve-deps|--no-resolve-deps|--keep-debootstrap-dir)
        # Unimportant options
        ;;
    --arch)
        ARCH="$2"
        shift
        ;;
    --arch=?*)
        ARCH="${1#*=}"
        ;;
    --unpack-tarball)
        TARBALL="$2"
        shift
        ;;
    --unpack-tarball=?*)
        TARBALL="${1#*=}"
        ;;
    --verbose)
        ;;
    (--) shift; break;;
    --help|-*)
        [ "$1" != "--help" ] && echo "Unknown option: $1"
        usage
        ;;
    (*) break;;
    esac
    shift
done

SUITE="$1"
TARGET="$2"

if [ ! "$SUITE" -o ! "$TARGET" ]; then
    usage
fi

declare -A URLs
declare -A URLs=( \
	["tumbleweed_armv6l"]="http://download.opensuse.org/ports/armv6hl/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS.armv6-rootfs.armv6l-Current.tbz" \
	["tumbleweed_armv7l"]="http://download.opensuse.org/ports/armv7hl/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS.armv7-rootfs.armv7l-Current.tbz" \
	["tumbleweed_aarch64"]="http://download.opensuse.org/ports/aarch64/tumbleweed/images/openSUSE-Tumbleweed-ARM-JeOS.aarch64-rootfs.aarch64-Current.tbz" \
	["tumbleweed_x86_64"]="http://download.opensuse.org/repositories/home:/algraf:/debootstrap/images/openSUSE-Tumbleweed-x86_64-JeOS.x86_64-rootfs.x86_64-Current.tbz" \
)

# Rename factory to tumbleweed
[ "$SUITE" = "factory" ] && SUITE=tumbleweed

key="${SUITE}_${ARCH}"
URL="${URLs["$key"]}"

if [ ! "$URL" ]; then
    echo "Unknown Distribution / Architecture: $key"
    exit 1
fi

if [ -e "$(which wget)" ]; then
    WGET="wget -O -"
elif [ -e "$(which curl)" ]; then
    WGET="curl"
else
    echo "No HTTP download tool found."
    exit 1
fi

if [ -e "$(which pbzip2)" ]; then
    BZIP2="pbzip2"
elif [ -e "$(which bzip2)" ]; then
    BZIP2="bzip2"
else
    echo "No HTTP download tool found."
    exit 1
fi

mkdir -p "$TARGET"
( cd "$TARGET"; $WGET $URL | $BZIP2 -d | tar x )

echo "done"
