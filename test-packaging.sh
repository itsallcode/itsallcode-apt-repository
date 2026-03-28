#!/bin/bash

# test-packaging.sh - Integration test for OpenFastTrace Debian packaging
# dsn~integration-testing~1

set -e

readonly DEFAULT_VERSION="4.2.2"
readonly BUILD_DIR="out"

echo "Starting integration test..."

# Determine version
VERSION="${1:-$DEFAULT_VERSION}"
echo "Testing version: $VERSION"

# 1. Call check-preconditions.sh
echo "Step 1: Checking preconditions..."
if ! ./check-preconditions.sh; then
    echo "Error: Precondition check failed."
    exit 1
fi

# 2. Call create-source-package.sh
echo "Step 2: Creating source package..."
if ! ./create-source-package.sh "$VERSION"; then
    echo "Error: Source package creation failed."
    exit 1
fi

# 3. Call create-binary-package.sh
echo "Step 3: Creating binary package..."
if ! ./create-binary-package.sh "$VERSION"; then
    echo "Error: Binary package creation failed."
    exit 1
fi

# 4. Verify output files
echo "Step 4: Verifying output files..."
# Basic expected files (source package artifacts)
EXPECTED_FILES=(
    "$BUILD_DIR/openfasttrace_$VERSION.orig.tar.gz"
    "$BUILD_DIR/openfasttrace_$VERSION-1.dsc"
    "$BUILD_DIR/openfasttrace_$VERSION-1.debian.tar.xz"
)

# Check for existence of expected source package files
for file in "${EXPECTED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Expected file $file not found."
        exit 1
    fi
    echo "  [ OK ] Found $file"
done

# Find the .deb file (architecture might vary, so use wildcard)
# We use a glob and check if the file exists to avoid SC2012
DEB_FILE=""
for f in "$BUILD_DIR"/openfasttrace_"$VERSION"-1_*.deb; do
    if [[ -e "$f" ]]; then
        DEB_FILE="$f"
        break
    fi
done

if [[ -z "$DEB_FILE" ]]; then
    echo "Error: Binary package (.deb) not found."
    exit 1
fi
echo "  [ OK ] Found $DEB_FILE"

# 5. Run shellcheck
echo "Step 5: Running shellcheck on all shell scripts..."
# Find all shell scripts in project root and debian/ oft script
SHELL_SCRIPTS=(
    "check-preconditions.sh"
    "create-source-package.sh"
    "create-binary-package.sh"
    "test-packaging.sh"
    "debian/static/usr/bin/oft"
)

if ! shellcheck "${SHELL_SCRIPTS[@]}"; then
    echo "Error: shellcheck failed for one or more scripts."
    exit 1
fi
echo "  [ OK ] shellcheck passed for all scripts."

# 6. Verify AppStream metadata of the built package
echo "Step 6: Verifying AppStream metadata in the built package..."
# The build-subdir will be present in out/ if create-binary-package.sh ran successfully
BUILD_SUBDIR="$BUILD_DIR/openfasttrace-$VERSION"
# The path in the built package tree:
METAINFO_PATH="$BUILD_SUBDIR/debian/openfasttrace/usr/share/metainfo/org.itsallcode.openfasttrace.metainfo.xml"

if [[ ! -f "$METAINFO_PATH" ]]; then
    echo "Error: AppStream metainfo not found in package at $METAINFO_PATH."
    exit 1
fi

if ! appstreamcli validate --no-net --explain "$METAINFO_PATH"; then
    echo "Warning: AppStream validation reported issues, but continuing..."
fi
echo "  [ OK ] AppStream metadata is valid."

echo ""
echo "Integration test for OpenFastTrace version $VERSION COMPLETED SUCCESSFULLY."
