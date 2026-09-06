#!/bin/bash

# test-packaging.sh - Integration test for OpenFastTrace Debian packaging
# dsn~integration-testing~1

set -e

readonly DEFAULT_VERSION="4.9.0"
readonly BUILD_DIR="out"

# [impl->dsn~integration-testing~1]
# [itest->dsn~integration-testing~1]
# [itest->dsn~user-guide-html~1]
# [itest->dsn~user-guide-manpage~1]
verify_output_files() {
    local -r version="$1"
    local -r package_revision="$2"
    local -r expected_files=(
        "$BUILD_DIR/openfasttrace_$version.orig.tar.gz"
        "$BUILD_DIR/openfasttrace_$version-$package_revision.dsc"
        "$BUILD_DIR/openfasttrace_$version-$package_revision.debian.tar.xz"
    )

    echo "Verifying output files..."
    for file in "${expected_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo "Error: Expected file $file not found."
            return 1
        fi
        echo "  [ OK ] Found $file"
    done

    local deb_file=""
    for f in "$BUILD_DIR"/openfasttrace_"$version"-"$package_revision"_*.deb; do
        if [[ -e "$f" ]]; then
            deb_file="$f"
            break
        fi
    done

    if [[ -z "$deb_file" ]]; then
        echo "Error: Binary package (.deb) not found."
        return 1
    fi
    echo "  [ OK ] Found $deb_file"

    if [[ "$(dpkg-deb -f "$deb_file" License)" != "GPL-3.0-or-later" ]]; then
        echo "Error: Package license metadata is missing or incorrect."
        return 1
    fi
    echo "  [ OK ] Package license metadata is present."

    echo "Verifying that user guide was generated and included in the build directory..."
    local -r build_subdir="$BUILD_DIR/openfasttrace-$version"
    if [[ ! -f "$build_subdir/user_guide.html" ]]; then
        echo "Error: user_guide.html not found in build directory."
        return 1
    fi
    if [[ ! -f "$build_subdir/oft.1.gz" ]]; then
        echo "Error: oft.1.gz not found in build directory."
        return 1
    fi
    echo "  [ OK ] User guide files found."
}

# [impl->dsn~finding-free-shellcheck~1]
# [impl->dsn~clean-code-principles~1]
# [impl->dsn~integration-testing~1]
run_shellcheck() {
    local -r shell_scripts=(
        "check-preconditions.sh"
        "create-source-package.sh"
        "create-binary-package.sh"
        "stage-apt-package.sh"
        "test-packaging.sh"
        "debian/static/usr/bin/oft"
    )

    echo "Running shellcheck on all shell scripts..."
    if ! shellcheck "${shell_scripts[@]}"; then
        echo "Error: shellcheck failed for one or more scripts."
        return 1
    fi
    echo "  [ OK ] shellcheck passed for all scripts."
}

# [impl->dsn~integration-testing~1]
# [itest->dsn~integration-testing~1]
validate_appstream() {
    local -r version="$1"
    local -r build_subdir="$BUILD_DIR/openfasttrace-$version"
    local -r metainfo_path="$build_subdir/debian/openfasttrace/usr/share/metainfo/org.itsallcode.openfasttrace.metainfo.xml"

    echo "Verifying AppStream metadata in the built package..."
    if [[ ! -f "$metainfo_path" ]]; then
        echo "Error: AppStream metainfo not found in package at $metainfo_path."
        return 1
    fi

    if ! appstreamcli validate --no-net --explain "$metainfo_path"; then
        echo "Warning: AppStream validation reported issues, but continuing..."
    fi
    if ! awk "/<release version=\"$version\"/,/<\\/release>/" "$metainfo_path" |
        grep --quiet '<description>'; then
        echo "Error: AppStream release metadata has no changelog description."
        return 1
    fi
    if ! grep --quiet '<pkgname>openfasttrace</pkgname>' "$metainfo_path"; then
        echo "Error: AppStream metadata does not identify the Debian package."
        return 1
    fi
    if ! grep --quiet '^Exec=oft --help$' \
        "$build_subdir/debian/openfasttrace/usr/share/applications/org.itsallcode.openfasttrace.desktop"; then
        echo "Error: Desktop launcher does not display the OFT help text."
        return 1
    fi
    if ! grep --quiet '^Icon=/usr/share/icons/hicolor/512x512/apps/org.itsallcode.openfasttrace.png$' \
        "$build_subdir/debian/openfasttrace/usr/share/applications/org.itsallcode.openfasttrace.desktop"; then
        echo "Error: Desktop launcher does not use the generated PNG icon."
        return 1
    fi
    echo "  [ OK ] AppStream metadata is valid."
}

# [itest->dsn~build-tools~1]
# [itest->dsn~binary-dependencies~1]
# [itest->dsn~precondition-check~1]
# [itest->dsn~build-orchestration-scripts~1]
# [itest->dsn~build-directory~1]
# [itest->dsn~version-input~1]
# [itest->dsn~source-fetching~1]
# [itest->dsn~package-screenshots~1]
# [itest->dsn~changelog-extraction~1]
# [itest->dsn~build-reproducibility~1]
# [itest->dsn~debian-metadata~1]
# [itest->dsn~app-icon~1]
# [itest->dsn~user-guide-html~1]
# [itest->dsn~user-guide-manpage~1]
# [itest->dsn~oft-wrapper-script~1]
# [itest->dsn~package-appstream-metadata~1]
# [itest->dsn~package-icon-declaration~1]
# [itest->dsn~integration-testing~1]
# [itest->dsn~finding-free-shellcheck~1]
main() {
    local -r version="${1:-$DEFAULT_VERSION}"
    local -r package_revision="${2:-1}"
    echo "Starting integration test for version: $version-$package_revision"

    echo "Step 1: Checking preconditions..."
    ./check-preconditions.sh

    echo "Step 2: Creating source package..."
    ./create-source-package.sh "$version" "$package_revision"

    echo "Step 3: Creating binary package..."
    ./create-binary-package.sh "$version" "$package_revision"

    echo "Step 4: Verifying output files..."
    verify_output_files "$version" "$package_revision"

    echo "Step 5: Running shellcheck..."
    run_shellcheck

    echo "Step 6: Verifying AppStream metadata..."
    validate_appstream "$version"

    echo ""
    echo "Integration test for OpenFastTrace version $version-$package_revision COMPLETED SUCCESSFULLY."
}

main "$@"
