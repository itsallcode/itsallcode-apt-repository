#!/bin/bash

# check-preconditions.sh - Verifies the build environment for OpenFastTrace Debian Package
# dsn~precondition-check~1, req~precondition-check~1

set -e

# Define required tools and their corresponding packages
# Tools are checked for existence in PATH
declare -A REQUIRED_TOOLS=(
    ["dpkg-buildpackage"]="dpkg-dev"
    ["dh"]="debhelper"
    ["dch"]="devscripts"
    ["curl"]="curl"
    ["wget"]="wget"
    ["shellcheck"]="shellcheck"
)

check_tools() {
    local missing_packages=()
    local all_ok=true

    echo "Checking for required tools..."
    for tool in "${!REQUIRED_TOOLS[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "  [FAIL] $tool is missing (provided by package: ${REQUIRED_TOOLS[$tool]})"
            missing_packages+=("${REQUIRED_TOOLS[$tool]}")
            all_ok=false
        else
            echo "  [ OK ] $tool is installed"
        fi
    done

    if [ "$all_ok" = false ]; then
        echo ""
        echo "Error: Some required tools are missing."
        echo "To install the missing packages, run:"
        echo "  sudo apt-get update && sudo apt-get install -y ${missing_packages[*]}"
        return 1
    else
        echo ""
        echo "All preconditions are met."
        return 0
    fi
}

# Main execution
check_tools
