# OpenFastTrace Debian Package

This project creates the Debian source and binary package for [OpenFastTrace ](https:/github.com/itsallcode/openfasttrace) (OFT), a requirement tracing suite.

## Notation

This specification uses the OFT requirement notation explained in the [OFT user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide.md).

## Goals

The packages created by this project must comply with the official Debian packaging requirements laid out in https://wiki.debian.org/Packaging.

## Roles

### Application Maintainer

The open source development team from [itsallcode](https://github.com/itsallcode) maintains the OpenFastTrace application to be packaged.

### Package Maintainer

The package maintainer builds the Debian package for OpenFastTrace, ensuring it adheres to Debian packaging standards and guidelines.

### Uploader

The uploader is responsible for uploading the Debian package to the Debian package repository, making it available for installation by users.

## Features

### Debian Source Package
`feat~debian-source-package~1`

The Debian source package includes all the necessary files and metadata to build the binary package, following Debian packaging conventions.

Rationale:

The Debian team requires that for each binary package, there must be a corresponding source package that can be used to rebuild the binary package. This ensures reproducibility and allows for easier maintenance and updates.

Needs: req

### Debian Binary Package
`feat~debian-binary-package~1`

The Debian binary package includes all files to install and run OpenFastTrace on Debian or a derived distribution.

Rationale:

End users of a debian-derived Linux distribution use this package type to install an application.

Needs: req

## High Level Requirements

### Debian Build Environment
`req~debian-build-environment~1`

The packages are built with the package building tools provided by the Debian project.

This project assumes that the build environment is Debian or a derived distribution.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)
* [`feat~debian-binary-package~1`](#feat~debian-binary-package~1)

Needs: dsn

### Precondition Check
`req~precondition-check~1`

The package maintainer runs a script that verifies that the preconditions are fulfilled before starting the actual package build. If anything is missing on the build system, the script lists commands to execute to install the missing parts.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)
* [`feat~debian-binary-package~1`](#feat~debian-binary-package~1)

Needs: dsn

### Source Package Build Automation by Shell Script
`req~source-package-build-automation-by-shell-script~1`

The automated build process for the source package is implemented by a shell script.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)

Needs: dsn

### Binary Package Build Automation by Shell Script
`req~binary-package-build-automation-by-shell-script~1`

The automated build process for the binary package is implemented by a shell script.

Covers:

* [`feat~debian-binary-package~1`](#debian-binary-package)

Needs: dsn

### Picking the Release
`req~picking-the-release~1`

The package maintainer picks the version number (format: `<major>.<minor>.<fix>`: e.g., 1.2.3) from which the source package is built.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)

Needs: dsn

### Binary Package From GitHub Release
`req~binary-package-from-git-hub-release~1`

The Package Maintainer creates a binary package from the source `.tar.gz.` of the GitHub release for the given version number of OFT under 
`https://github.com/itsallcode/openfasttrace/archive/refs/tags/<version>.tar.gz`.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)

Needs: dsn

### Reproducible Build From Source Package
`req~reproducible-build-from-source-package~1`

The binary is built reproducibly from the source package.

Covers:

* [`feat~debian-binary-package~1`](#feat~debian-binary-package~1)

Needs: dsn

### Package Metadata

`req~package-metadata~1`

The packages must include the following constant metadata:

* Organization: itsallcode
* Maintainers:
  * Christoph Pirkl <christoph@chp1.net>
  * Sebastian Bär <sebastian@baer.zone>
* Homepage URL: https://github.com/itsallcode/openfasttrace
* Source URL: https://github.com/itsallcode/openfasttrace-debian-package
* License: GPL-3.0
* Short Description: Requirement tracing suite for agile projects
* Long Description: OpenFastTrace (OFT) is a requirement tracing suite. It helps developers and project managers track requirements throughout the software development lifecycle.

Rationale:

Debian packages require consistent metadata to ensure proper identification, licensing compliance, and user information.
This metadata is used by package managers and documentation tools.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)
* [`feat~debian-binary-package~1`](#debian-binary-package)

Needs: dsn

### Debian Changelog
`req~debian-changelog~1`

The debian-style change log is derived from the changelog Markdown files found in the project under `doc/changes`. The debian changelog only gets appended to, never rewritten.

Rationale:

OFT already has a well-maintained changelog that serves as the source of truth for the package changelog. Appending ensures that reviewed changes are not modified. This is especially useful when the new entries are extracted automatically with a tool and need human review.

Covers:

* [`feat~debian-source-package~1`](#debian-source-package)
* [`feat~debian-binary-package~1`](#debian-binary-package)

Needs: dsn
