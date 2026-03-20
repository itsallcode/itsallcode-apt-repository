#!/bin/bash

# create-source-package.sh - Automates the creation of the Debian source package
# dsn~build-orchestration-scripts~1, dsn~version-input~1, dsn~source-fetching~1, dsn~changelog-extraction~1

set -e

readonly OFT_REPO_URL="https://github.com/itsallcode/openfasttrace"
readonly DEBFULLNAME="Sebastian Bär"
readonly DEBEMAIL="sebastian@baer.zone"
readonly BUILD_DIR="out"
export DEBFULLNAME DEBEMAIL

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

download_source() {
    local version="$1"
    local tarball="$BUILD_DIR/openfasttrace-$version.tar.gz"
    local url="$OFT_REPO_URL/archive/refs/tags/$version.tar.gz"

    echo "Downloading source for version $version..."
    wget -O "$tarball" "$url"
}

extract_source() {
    local tarball="$1"
    local version="$2"
    echo "Extracting source $tarball..."
    # Ensure a clean extraction directory to avoid issues with stale files from previous builds
    rm -rf "$BUILD_DIR/openfasttrace-$version"
    tar -xzf "$tarball" -C "$BUILD_DIR"
}

update_changelog() {
    local version="$1"
    local source_dir="$BUILD_DIR/openfasttrace-$version"
    local changes_dir="$source_dir/doc/changes"

    echo "Updating debian/changelog from $changes_dir..."

    if [[ ! -d "$changes_dir" ]]; then
        echo "Warning: No changes directory found in source." >&2
        return
    fi

    # Find relevant Markdown files in doc/changes
    # In OFT, changes are usually in files like changes_<version>.md
    local change_file="$changes_dir/changes_$version.md"
    if [[ ! -f "$change_file" ]]; then
        echo "Warning: No change file found for version $version at $change_file" >&2
        # Fallback: maybe there are other files?
        # For now, let's assume the file exists as per dsn~changelog-extraction~1
        # and if not, we just add a generic entry.
        dch --newversion "$version-1" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    # Convert Markdown to Debian changelog format
    # Simple conversion: strip # headings and use the content as list items
    # OFT change files usually have:
    # # <version>
    # * <change 1>
    # * <change 2>
    
    local temp_changelog_msg
    temp_changelog_msg=$(mktemp)
    # Extract lines starting with * or - and clean them up
    grep -E '^\s*[\*\-]\s+' "$change_file" | sed -E 's/^\s*[\*\-]\s+//' > "$temp_changelog_msg"
    
    if [[ ! -s "$temp_changelog_msg" ]]; then
        echo "No changes found in $change_file, using generic message."
        echo "New upstream release $version" > "$temp_changelog_msg"
    fi

    # Update debian/changelog using dch
    # We use --newversion to set the version and --distribution to set the distribution
    # We'll use the content of temp_changelog_msg as the first entry and then add others
    
    local first_line
    first_line=$(head -n 1 "$temp_changelog_msg")
    dch --newversion "$version-1" --distribution unstable --force-distribution "$first_line"
    
    # Add subsequent lines if they exist
    tail -n +2 "$temp_changelog_msg" | while read -r line; do
        if [[ -n "$line" ]]; then
            dch --append "$line"
        fi
    done
    
    rm "$temp_changelog_msg"
}

prepare_debian_source() {
    local version="$1"
    local source_dir="$BUILD_DIR/openfasttrace-$version"
    local orig_tarball="$BUILD_DIR/openfasttrace_$version.orig.tar.gz"

    # Debian expects the upstream tarball to be named <package>_<version>.orig.tar.gz
    cp "$BUILD_DIR/openfasttrace-$version.tar.gz" "$orig_tarball"

    # Copy debian/ directory into the extracted source
    cp -r debian/ "$source_dir/"

    echo "Creating Debian source package..."
    # Artifacts are created in the parent directory of where dpkg-source is run
    (cd "$source_dir" && dpkg-source -b .)
}

cleanup() {
    local version="$1"
    echo "Cleaning up extraction directory..."
    rm -rf "$BUILD_DIR/openfasttrace-$version"
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
    download_source "$version"
    extract_source "$BUILD_DIR/openfasttrace-$version.tar.gz" "$version"
    update_changelog "$version"
    prepare_debian_source "$version"
    cleanup "$version"

    echo "Source package for version $version created successfully in $BUILD_DIR."
}

main "$@"
