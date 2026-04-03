#!/bin/bash

# create-source-package.sh - Automates the creation of the Debian source package
# dsn~build-orchestration-scripts~1, dsn~version-input~1, dsn~source-fetching~1, dsn~changelog-extraction~1, dsn~package-screenshots~1

set -e

readonly OFT_REPO_URL="https://github.com/itsallcode/openfasttrace"
readonly DEBFULLNAME="Sebastian Bär"
readonly DEBEMAIL="sebastian@baer.zone"
readonly BUILD_DIR="out"
export DEBFULLNAME DEBEMAIL

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

# [impl->dsn~source-fetching~1]
download_source() {
    local -r version="$1"
    local -r tarball="$BUILD_DIR/openfasttrace-$version.tar.gz"
    local -r url="$OFT_REPO_URL/archive/refs/tags/$version.tar.gz"

    echo "Downloading source for version $version..."
    wget -O "$tarball" "$url"
}

# [impl->dsn~package-screenshots~1]
download_screenshots() {
    local -r screenshots_dir="debian/static/usr/share/metainfo/screenshots"
    local -r raw_url="https://raw.githubusercontent.com/itsallcode/openfasttrace/refs/heads/main/doc/images"
    local -r screenshots=(
        "oft_screenshot_tracing_report.png"
        "oft_screenshot_help.png"
        "oft_screenshot_markdown_import_trace.png"
    )

    echo "Downloading up-to-date screenshots from upstream main branch..."
    mkdir -p "$screenshots_dir"
    
    # Remove old screenshots to ensure only the requested ones are included
    rm -f "$screenshots_dir"/*.png

    for img in "${screenshots[@]}"; do
        echo "  Downloading $img..."
        wget -q -O "$screenshots_dir/$img" "$raw_url/$img"
    done
}

# [impl->dsn~build-orchestration-scripts~1]
extract_source() {
    local -r tarball="$1"
    local -r version="$2"
    echo "Extracting source $tarball..."
    # Ensure a clean extraction directory to avoid issues with stale files from previous builds
    rm -rf "$BUILD_DIR/openfasttrace-$version"
    tar -xzf "$tarball" -C "$BUILD_DIR"
}

# [impl->dsn~changelog-extraction~1]
extract_markdown_changes() {
    local -r change_file="$1"
    local -r temp_file="$2"

    # Extract lines starting with * or - and clean them up
    # Simple conversion: strip * or - bullets and use the content
    grep -E '^\s*[\*\-]\s+' "$change_file" | sed -E 's/^\s*[\*\-]\s+//' > "$temp_file"
}

# [impl->dsn~changelog-extraction~1]
apply_changelog_entries() {
    local -r version="$1"
    local -r entries_file="$2"

    if [[ ! -s "$entries_file" ]]; then
        echo "No changes found, using generic message."
        dch --newversion "$version-1" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    local -r first_line=$(head -n 1 "$entries_file")
    dch --newversion "$version-1" --distribution unstable --force-distribution "$first_line"
    
    # Add subsequent lines if they exist
    tail -n +2 "$entries_file" | while read -r line; do
        if [[ -n "$line" ]]; then
            dch --append "$line"
        fi
    done
}

# [impl->dsn~changelog-extraction~1]
update_changelog() {
    local -r version="$1"
    local -r source_dir="$BUILD_DIR/openfasttrace-$version"
    local -r changes_dir="$source_dir/doc/changes"
    local -r change_file="$changes_dir/changes_$version.md"

    echo "Updating debian/changelog from $changes_dir..."

    if [[ ! -d "$changes_dir" ]]; then
        echo "Warning: No changes directory found in source." >&2
        dch --newversion "$version-1" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    if [[ ! -f "$change_file" ]]; then
        echo "Warning: No change file found for version $version at $change_file" >&2
        dch --newversion "$version-1" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    local -r temp_changelog_msg=$(mktemp)
    extract_markdown_changes "$change_file" "$temp_changelog_msg"
    apply_changelog_entries "$version" "$temp_changelog_msg"
    rm "$temp_changelog_msg"
}

# [impl->dsn~build-orchestration-scripts~1]
prepare_debian_source() {
    local -r version="$1"
    local -r source_dir="$BUILD_DIR/openfasttrace-$version"
    local -r orig_tarball="$BUILD_DIR/openfasttrace_$version.orig.tar.gz"

    # Debian expects the upstream tarball to be named <package>_<version>.orig.tar.gz
    cp "$BUILD_DIR/openfasttrace-$version.tar.gz" "$orig_tarball"

    # Copy debian/ directory into the extracted source
    cp -r debian/ "$source_dir/"

    echo "Creating Debian source package..."
    # Artifacts are created in the parent directory of where dpkg-source is run
    (cd "$source_dir" && dpkg-source -b .)
}

# [impl->dsn~build-orchestration-scripts~1]
cleanup_extraction() {
    local -r version="$1"
    echo "Cleaning up extraction directory..."
    rm -rf "$BUILD_DIR/openfasttrace-$version"
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
    download_source "$version"
    download_screenshots
    extract_source "$BUILD_DIR/openfasttrace-$version.tar.gz" "$version"
    update_changelog "$version"
    prepare_debian_source "$version"
    cleanup_extraction "$version"

    echo "Source package for version $version created successfully in $BUILD_DIR."
}

main "$@"
