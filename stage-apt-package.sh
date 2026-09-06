#!/bin/bash

# stage-apt-package.sh - Stages built Debian packages in the APT archive pool

set -euo pipefail

readonly BUILD_DIR="out"
readonly PACKAGE_NAME="openfasttrace"
readonly ARCHIVE_POOL_DIR="apt-repository/pool/main/o/openfasttrace"

validate_version() {
    local -r version="$1"
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid version format '$version'. Expected <major>.<minor>.<fix>." >&2
        return 1
    fi
}

validate_package_revision() {
    local -r package_revision="$1"
    if [[ ! "$package_revision" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid Debian package revision '$package_revision'. Expected a positive integer." >&2
        return 1
    fi
}

require_file() {
    local -r file="$1"
    if [[ ! -f "$file" ]]; then
        echo "Error: Required package artifact not found: $file" >&2
        return 1
    fi
}

validate_binary_package() {
    local -r package_file="$1"
    local -r expected_version="$2"

    if [[ "$(dpkg-deb --field "$package_file" Package)" != "$PACKAGE_NAME" ]]; then
        echo "Error: $package_file is not an $PACKAGE_NAME package." >&2
        return 1
    fi

    if [[ "$(dpkg-deb --field "$package_file" Version)" != "$expected_version" ]]; then
        echo "Error: $package_file does not have version $expected_version." >&2
        return 1
    fi

    if [[ "$(dpkg-deb --field "$package_file" Architecture)" != "all" ]]; then
        echo "Error: $package_file is not architecture-independent." >&2
        return 1
    fi
}

stage_artifacts() {
    local -r version="$1"
    local -r package_revision="$2"
    local -r package_version="$version-$package_revision"
    local -r orig_tarball="$BUILD_DIR/${PACKAGE_NAME}_${version}.orig.tar.gz"
    local -r debian_tarball="$BUILD_DIR/${PACKAGE_NAME}_${package_version}.debian.tar.xz"
    local -r dsc_file="$BUILD_DIR/${PACKAGE_NAME}_${package_version}.dsc"
    local -r binary_package="$BUILD_DIR/${PACKAGE_NAME}_${package_version}_all.deb"
    local -r checksum_file="$ARCHIVE_POOL_DIR/${PACKAGE_NAME}_${package_version}.SHA256SUMS"
    local -a artifacts=("$orig_tarball" "$debian_tarball" "$dsc_file" "$binary_package")

    for artifact in "${artifacts[@]}"; do
        require_file "$artifact"
    done
    validate_binary_package "$binary_package" "$package_version"

    mkdir --parents "$ARCHIVE_POOL_DIR"
    install --mode=0644 "${artifacts[@]}" "$ARCHIVE_POOL_DIR"

    (
        cd "$ARCHIVE_POOL_DIR"
        sha256sum \
            "${PACKAGE_NAME}_${version}.orig.tar.gz" \
            "${PACKAGE_NAME}_${package_version}.debian.tar.xz" \
            "${PACKAGE_NAME}_${package_version}.dsc" \
            "${PACKAGE_NAME}_${package_version}_all.deb" \
            > "${PACKAGE_NAME}_${package_version}.SHA256SUMS"
    )

    echo "Staged package $package_version in $ARCHIVE_POOL_DIR."
    echo "Checksum manifest: $checksum_file"
}

main() {
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "Usage: $0 <version> [package-revision]" >&2
        exit 1
    fi

    local -r version="$1"
    local -r package_revision="${2:-1}"
    validate_version "$version"
    validate_package_revision "$package_revision"
    stage_artifacts "$version" "$package_revision"
}

main "$@"
