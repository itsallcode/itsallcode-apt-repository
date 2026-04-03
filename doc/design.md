# OpenFastTrace Debian Package Design

This document describes the design of the OpenFastTrace Debian Package project.

## Notation

This design uses the OFT requirement notation explained in the [OFT user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide.md).

Requirements in this document are always formulated in present as if they were already implemented. This fits with the idea that OFT specs are traced down to implementation and test and are also up to date.

In the implementation, the covering code is marked with:

```shell
# [impl->dsn~<id>~<revision>]
```

Integration tests are marked with:

```shell
# [itest->dsn~<id>~<revision>]
```
Coverage is marked before functions. Multiple coverage markers can appear before the same function. Design, implementation, and test coverage cannot be in the same file.

The "Needs" field in a requirement tells OFT, which artifact types are required to implement or test the requirement. For each required coverage at least one coverage marker must be present.

## Components

### Build Environment and Tools
`dsn~build-tools~1`

The project relies on standard Debian package building tools such as `dpkg-dev`, `debhelper`, `devscripts`, `pandoc`, and `imagemagick`. These tools must be installed on a Debian or derived distribution to facilitate the build process.

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

The `create-source-package.sh` script uses `wget` to download the OpenFastTrace source code for the specified version directly from GitHub as a `.tar.gz` archive from `https://github.com/itsallcode/openfasttrace/archive/refs/tags/<version>.tar.gz` where `<version>` is the version number of OFT for which the package should be built.

Covers:
* [`req~binary-package-from-git-hub-release~1`](system_requirements.md#binary-package-from-git-hub-release)

Needs: impl, itest

### Debian Package Structure and Metadata
`dsn~debian-metadata~1`

The project maintains a `debian/` directory containing the standard metadata files:
* `control`: Package information, dependencies, and descriptions (using the specified Debian Package Maintainer).
* `changelog`: Version history and maintainer information.
* `copyright`: License and authorship information (using the specified Upstream Authors).
* `rules`: Build instructions for `dpkg-buildpackage`.

To simplify the installation process, static content like the desktop file, icons, and AppStream metainfo are pre-placed in the `debian/static/` directory, reflecting their final installation paths in the binary package. The `rules` file is responsible for moving this content to the correct locations and installing any additional generated artifacts.

These files are populated with the constant metadata defined in the requirements.

Covers:
* [`req~package-metadata~1`](system_requirements.md#package-metadata)

Needs: impl,itest

### Binary Dependencies
`dsn~binary-dependencies~1`

The `debian/control` file declares a dependency on `openjdk-17-jre-headless` or a newer version to ensure the runtime environment is available.

Covers:
* [`req~binary-dependencies~1`](system_requirements.md#binary-dependencies)

Needs: itest

### OFT Wrapper Script
`dsn~oft-wrapper-script~1`

A shell script named `oft` provides in the binary package (typically installed to `/usr/bin/oft`). This script will facilitate the execution of the OpenFastTrace JAR file by invoking the Java Runtime Environment with the necessary parameters.

Covers:
* [`req~oft-wrapper-script~1`](system_requirements.md#oft-wrapper-script)

Needs: impl, itest

### Application Icon
`dsn~app-icon~1`

The application logo is included in the binary package in SVG and multiple PNG formats. A square SVG app icon is pre-placed in the project at `debian/static/usr/share/icons/hicolor/scalable/apps/org.itsallcode.openfasttrace.svg` to serve as the source for all icons. This specific icon is used instead of the rectangular upstream logo.

PNG icons in various sizes (from 16x16 up to 1024x1024) and scales (including @2) are generated from this square SVG icon during the build process using ImageMagick's `convert` tool and installed to their respective `/usr/share/icons/hicolor/<size>/apps/org.itsallcode.openfasttrace.png` or `/usr/share/icons/hicolor/<size>@2/apps/org.itsallcode.openfasttrace.png` directories to support modern icon themes and AppStream indexing.

Covers:
* [`req~scaled-app-icons~1`](system_requirements.md#scaled-app-icons)

Needs: impl,itest

### Package AppStream Metadata
`dsn~package-appstream-metadata~1`

The AppStream metadata (`/usr/share/metainfo/org.itsallcode.openfasttrace.metainfo.xml`) is configured as a `desktop-application`. It uses `GPL-3.0-or-later` as the project license and includes a full OARS 1.1 content rating to ensure it is correctly classified by software centers. It also includes release information.

Covers:
* [`req~package-appstream-metadata~1`](system_requirements.md#package-appstream-metadata)

Needs: impl,itest

### Package Icon Declaration
`dsn~package-icon-declaration~1`

The package declares its icon using:
1.  A standard Desktop Entry file (`/usr/share/applications/org.itsallcode.openfasttrace.desktop`) that specifies `Icon=org.itsallcode.openfasttrace` and `Terminal=true`.
2.  AppStream metadata (`/usr/share/metainfo/org.itsallcode.openfasttrace.metainfo.xml`) that references the desktop file and identifies the application with `<launchable type="desktop-id">org.itsallcode.openfasttrace.desktop</launchable>` and `<icon type="themed">org.itsallcode.openfasttrace</icon>`.

Covers:
* [`req~package-icon-declaration~1`](system_requirements.md#package-icon-declaration)

Needs: impl,itest

### Package Screenshots
`dsn~package-screenshots~1`

The AppStream metadata (`/usr/share/metainfo/org.itsallcode.openfasttrace.metainfo.xml`) includes a `<screenshots>` section. For maximum compatibility with AppStream validation tools and software centers, screenshots are referenced via stable raw GitHub URLs from the upstream repository's main branch. To ensure offline availability and support for all tools, these images are also downloaded during the build process and packed into the package at `/usr/share/metainfo/screenshots/`.

Covers:
* [`req~package-screenshots~1`](system_requirements.md#package-screenshots)

Needs: impl, itest

### HTML User Guide
`dsn~user-guide-html~1`

The build process uses `pandoc` to convert the `doc/user_guide.md` file from the upstream source into an HTML version. This file is installed into the binary package at `/usr/share/doc/openfasttrace/user_guide.html`.

Covers:
* [`req~user-guide-html~1`](system_requirements.md#html-user-guide-in-binary-package)

Needs: impl, itest

### Man Page User Guide
`dsn~user-guide-manpage~1`

The build process uses `pandoc` to convert the `doc/user_guide.md` file from the upstream source into a manpage format. The generated manpage is installed into the binary package at `/usr/share/man/man1/oft.1.gz`.

Covers:
* [`req~user-guide-manpage~1`](system_requirements.md#man-page-user-guide-in-binary-package)

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

### Dedicated Build Directory
`dsn~build-directory~1`

The project uses a dedicated directory named `out/` in the project root to store all build artifacts, including downloaded source archives, extracted directories, and the resulting Debian source and binary packages.
All build scripts are responsible for creating this directory if it doesn't exist and moving generated artifacts into it.

Covers:
* [`req~build-directory~1`](system_requirements.md#build-directory)

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

1. Speaking function and variable names instead of comments
2. Functions have a low complexity
3. Processing steps are represented as individual functions
4. Minimal but well-readable implementation
5. Minimal dependencies
6. Immutable variables where possible
7. Local variables where possible
8. All user input is validated before use
9. 100% test coverage

Needs: impl

### Finding-free Shellcheck
`dsn~finding-free-shellcheck~1`

All shell scripts in this project are free of findings in shellcheck.

Needs: impl, itest
