# OpenFastTrace Debian Package Design

This document describes the design of the OpenFastTrace Debian Package project.

## Notation

This design uses the OFT requirement notation explained in the [OFT user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide.md).

## Components

### Build Environment and Tools
`dsn~build-tools~1`

The project relies on standard Debian package building tools such as `dpkg-dev`, `debhelper`, and `devscripts`. These tools must be installed on a Debian or derived distribution to facilitate the build process.

Covers:
* [`req~debian-build-environment~1`](system_requirements.md#debian-build-environment)

Needs: impl, itest

### Build Orchestration Scripts
`dsn~build-orchestration-scripts~1`

Two main shell scripts will be provided to automate the packaging process:
1. `create-source-package.sh`: Automates the creation of the Debian source package.
2. `create-binary-package.sh`: Automates the creation of the Debian binary package from the source package.

Covers:
* [`req~source-package-build-automation-by-shell-script~1`](system_requirements.md#source-package-build-automation-by-shell-script)
* [`req~binary-package-build-automation-by-shell-script~1`](system_requirements.md#binary-package-build-automation-by-shell-script)

Needs: impl, itest

### Precondition Check
`dsn~precondition-check~1`

A dedicated shell script `check-preconditions.sh` will be implemented to verify that the build environment meets all requirements (e.g., necessary tools installed). This script will be called by the build orchestration scripts before they proceed.

Covers:
* [`req~precondition-check~1`](system_requirements.md#precondition-check)

Needs: impl, itest

### Version Handling and Input
`dsn~version-input~1`

The version of OpenFastTrace to be packaged will be passed as a command-line argument to the build scripts. The version format must follow the `<major>.<minor>.<fix>` pattern.

Covers:
* [`req~picking-the-release~1`](system_requirements.md#picking-the-release)

Needs: impl, itest

### Source Fetching from GitHub
`dsn~source-fetching~1`

The `create-source-package.sh` script will use `curl` or `wget` to download the OpenFastTrace source code for the specified version directly from GitHub as a `.tar.gz` archive.

Covers:
* [`req~binary-package-from-git-hub-release~1`](system_requirements.md#binary-package-from-git-hub-release)

Needs: impl, itest

### Debian Package Structure and Metadata
`dsn~debian-metadata~1`

The project will maintain a `debian/` directory containing the standard metadata files:
* `control`: Package information, dependencies, and descriptions (using the specified Debian Package Maintainer).
* `changelog`: Version history and maintainer information.
* `copyright`: License and authorship information (using the specified Upstream Authors).
* `rules`: Build instructions for `dpkg-buildpackage`.

These files will be populated with the constant metadata defined in the requirements.

Covers:
* [`req~package-metadata~1`](system_requirements.md#package-metadata)

Needs: impl, itest

### Changelog Extraction
`dsn~changelog-extraction~1`

The `create-source-package.sh` script will extract changelog entries from the Markdown files in the `doc/changes` directory of the fetched OpenFastTrace source code.
The extraction process will:
* Identify the Markdown files relevant to the version being packaged.
* Convert the Markdown content into the Debian changelog format.
* Append the formatted entries to `debian/changelog`, ensuring that existing history is never rewritten.

Covers:
* [`req~debian-changelog~1`](system_requirements.md#debian-changelog)

Needs: impl, itest

### Reproducible Build Process
`dsn~build-reproducibility~1`

The `create-binary-package.sh` script will utilize `dpkg-buildpackage -us -uc -b` to build the binary package from the extracted source package. This process ensures that the resulting binary package is built consistently and reproducibly from the source files.

Covers:
* [`req~reproducible-build-from-source-package~1`](system_requirements.md#reproducible-build-from-source-package)

Needs: impl, itest

### Integration Testing
`dsn~integration-testing~1`

A simple integration test will be implemented as a shell script `test-packaging.sh`. This script will:
1. Call `check-preconditions.sh` to verify the environment.
2. Call `create-source-package.sh` for a specific version.
3. Call `create-binary-package.sh` for the same version.
4. Verify that the output files (`.dsc`, `.orig.tar.gz`, `.debian.tar.xz`, and `.deb`) are present.
5. Run `shellcheck` on all shell scripts.

Needs: impl, itest

## Quality Requirements

The requirements in this section are of a technical nature and don't cover end user requirements from the [system requirments](system_requirements.md). They ensure that the code stays clean and maintainable.

### Clean Code Principles
`dsn~clean-code-principles~1`

The project adheres to the following clean code principles:

1. Speaking function names instead of comments
2. Functions have a low complexity
3. Steps are represented as individual functions
4. Minimal but well-readable implementation
5. Minimal dependencies
6. Immutable variables where possible

Needs: impl

### Finding-free Shellcheck
`dsn~finding-free-shellcheck~1`

All shell scripts in this project are free of findings in shellcheck.

Needs: impl, itest



