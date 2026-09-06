#!/bin/bash

# create-source-package.sh - Automates the creation of the Debian source package
# dsn~build-orchestration-scripts~1, dsn~version-input~1, dsn~source-fetching~1, dsn~changelog-extraction~1, dsn~package-screenshots~1

set -e

readonly OFT_REPO_URL="https://github.com/itsallcode/openfasttrace"
readonly DEBFULLNAME="itsallcode.org"
readonly DEBEMAIL="maintainers@itsallcode.org"
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

validate_package_revision() {
    local -r package_revision="$1"
    if [[ ! "$package_revision" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Invalid Debian package revision '$package_revision'. Expected a positive integer." >&2
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

    # 1. Extract Summary content (from ## Summary until the next ## or end of file)
    sed -n '/## Summary/,/##/p' "$change_file" | grep -v '##' | sed -E 's/^[[:space:]]*([*\-][[:space:]]*)?//; s/\*\*//g; s/`//g; /^[[:space:]]*$/d' > "$temp_file"

    # 2. Extract bullets from other sections but skip "Dependency Updates" and "Plugin Updates"
    awk '/^## / {section=$0; next}
         section !~ /Dependency Updates|Plugin Updates|Summary/ && /^[[:space:]]*[\*\-]/ {
             sub(/^[[:space:]]*[\*\-][[:space:]]*/, "");
             print $0
         }' "$change_file" >> "$temp_file"
}

# [impl->dsn~changelog-extraction~1]
apply_changelog_entries() {
    local -r version="$1"
    local -r package_revision="$2"
    local -r entries_file="$3"
    local -r debian_version="$version-$package_revision"

    # Check if version already exists in changelog
    if dpkg-parsechangelog -S Version | grep -q "^$debian_version$"; then
        echo "Version $debian_version already exists in debian/changelog. Skipping."
        return
    fi

    if [[ ! -s "$entries_file" ]]; then
        echo "No changes found, using generic message."
        dch --newversion "$debian_version" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    local -r first_line=$(head -n 1 "$entries_file")
    dch --newversion "$debian_version" --distribution unstable --force-distribution "$first_line"

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
    local -r package_revision="$2"
    local -r source_dir="$BUILD_DIR/openfasttrace-$version"
    local -r changes_dir="$source_dir/doc/changes"
    local -r change_file="$changes_dir/changes_$version.md"

    echo "Updating debian/changelog from $changes_dir..."

    if [[ ! -d "$changes_dir" ]]; then
        echo "Warning: No changes directory found in source." >&2
        dch --newversion "$version-$package_revision" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    if [[ ! -f "$change_file" ]]; then
        echo "Warning: No change file found for version $version at $change_file" >&2
        dch --newversion "$version-$package_revision" --distribution unstable --force-distribution "New upstream release $version"
        return
    fi

    local -r temp_changelog_msg=$(mktemp)
    extract_markdown_changes "$change_file" "$temp_changelog_msg"
    apply_changelog_entries "$version" "$package_revision" "$temp_changelog_msg"
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
    if [[ $# -lt 1 || $# -gt 2 ]]; then
        echo "Usage: $0 <version> [package-revision]" >&2
        exit 1
    fi

    local -r version="$1"
    local -r package_revision="${2:-1}"
    validate_version "$version"
    validate_package_revision "$package_revision"
    
    verify_preconditions
    ensure_build_dir
    download_source "$version"
    download_screenshots
    extract_source "$BUILD_DIR/openfasttrace-$version.tar.gz" "$version"
    update_changelog "$version" "$package_revision"
    prepare_debian_source "$version"
    cleanup_extraction "$version"

    echo "Source package for version $version-$package_revision created successfully in $BUILD_DIR."
}

main "$@"
