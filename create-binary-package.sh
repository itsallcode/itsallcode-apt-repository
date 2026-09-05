#!/bin/bash

# create-binary-package.sh - Automates the creation of the Debian binary package
# dsn~build-orchestration-scripts~1, dsn~build-reproducibility~1

set -e

readonly BUILD_DIR="out"

# [impl->dsn~build-orchestration-scripts~1]
verify_preconditions() {
    ./check-preconditions.sh
}

# [impl->dsn~build-directory~1]
ensure_build_dir() {
    mkdir -p "$BUILD_DIR"
}

# [impl->dsn~version-input~1]
validate_version() {
    local -r version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format '$version'. Expected <major>.<minor>.<fix>." >&2
        return 1
    fi
}

# [impl->dsn~build-orchestration-scripts~1]
check_source_package_exists() {
    local -r version="$1"
    local -r dsc_file="$BUILD_DIR/openfasttrace_$version-1.dsc"
    local -r orig_tarball="$BUILD_DIR/openfasttrace_$version.orig.tar.gz"
    local -r debian_tarball="$BUILD_DIR/openfasttrace_$version-1.debian.tar.xz"

    if [[ ! -f "$dsc_file" ]]; then
        echo "Error: Source package control file not found at $dsc_file." >&2
        echo "Please run ./create-source-package.sh $version first." >&2
        return 1
    fi

    if [[ ! -f "$orig_tarball" || ! -f "$debian_tarball" ]]; then
        echo "Error: Incomplete source package in $BUILD_DIR." >&2
        return 1
    fi
}

# [impl->dsn~build-orchestration-scripts~1]
extract_source_package() {
    local -r version="$1"
    local -r dsc_file="openfasttrace_${version}-1.dsc"
    local -r build_subdir="$BUILD_DIR/openfasttrace-$version"

    echo "Cleaning up any existing build directory $build_subdir..."
    rm -rf "$build_subdir"

    echo "Extracting source package to $BUILD_DIR..."
    (cd "$BUILD_DIR" && dpkg-source -x "$dsc_file")
}

# [impl->dsn~build-reproducibility~1]
build_binary_package() {
    local -r build_subdir="$BUILD_DIR/openfasttrace-$1"
    echo "Building binary package (including HTML and manpage user guide)..."
    (cd "$build_subdir" && dpkg-buildpackage -us -uc -b)
}

# [impl->dsn~build-orchestration-scripts~1]
main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <version>" >&2
        exit 1
    fi

    local -r version="$1"
    validate_version "$version"
    
    verify_preconditions
    ensure_build_dir
    check_source_package_exists "$version"
    extract_source_package "$version"
    build_binary_package "$version"

    echo ""
    echo "Binary package for version $version created successfully in $BUILD_DIR."
    ls -l "$BUILD_DIR"/openfasttrace_"$version"-1_*.deb
}

main "$@"
