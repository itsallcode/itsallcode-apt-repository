#!/bin/bash

# create-binary-package.sh - Automates the creation of the Debian binary package
# dsn~build-orchestration-scripts~1, dsn~build-reproducibility~1

set -e

readonly BUILD_DIR="out"

verify_preconditions() {
    ./check-preconditions.sh
}

ensure_build_dir() {
    mkdir -p "$BUILD_DIR"
}

parse_version() {
    local version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format '$version'. Expected <major>.<minor>.<fix>." >&2
        exit 1
    fi
    echo "$version"
}

main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <version>" >&2
        exit 1
    fi

    local version
    version=$(parse_version "$1")
    
    verify_preconditions
    ensure_build_dir

    local dsc_file="$BUILD_DIR/openfasttrace_$version-1.dsc"
    if [[ ! -f "$dsc_file" ]]; then
        echo "Error: Source package control file not found at $dsc_file." >&2
        echo "Please run ./create-source-package.sh $version first." >&2
        exit 1
    fi

    # Ensure all required files for extraction are present in the same directory
    local orig_tarball="$BUILD_DIR/openfasttrace_$version.orig.tar.gz"
    local debian_tarball="$BUILD_DIR/openfasttrace_$version-1.debian.tar.xz"
    if [[ ! -f "$orig_tarball" || ! -f "$debian_tarball" ]]; then
        echo "Error: Incomplete source package in $BUILD_DIR." >&2
        exit 1
    fi

    local build_subdir="$BUILD_DIR/openfasttrace-$version"
    echo "Cleaning up any existing build directory $build_subdir..."
    rm -rf "$build_subdir"

    echo "Extracting source package to $BUILD_DIR..."
    # dpkg-source -x extracts into the directory named after the package/version
    # We run it from within the BUILD_DIR to ensure it finds the tarballs
    (cd "$BUILD_DIR" && dpkg-source -x "$(basename "$dsc_file")")

    echo "Building binary package (including HTML and manpage user guide)..."
    # Run dpkg-buildpackage -us -uc -b from within the extracted source
    (cd "$build_subdir" && dpkg-buildpackage -us -uc -b)

    echo ""
    echo "Binary package for version $version created successfully in $BUILD_DIR."
    ls -l "$BUILD_DIR"/openfasttrace_"$version"-1_*.deb
}

main "$@"
