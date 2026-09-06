# <img src="https://raw.githubusercontent.com/itsallcode/openfasttrace/main/core/src/main/resources/openfasttrace_logo.svg" alt="OFT logo" width="150"/> OpenFastTrace Debian Package

This repository builds Debian packages for [OpenFastTrace](https://github.com/itsallcode/openfasttrace) (OFT), a requirement tracing suite. OFT keeps track of whether you implemented everything planned in your specifications and identifies obsolete parts of a product.

[![Build Debian package](https://github.com/itsallcode/openfasttrace-debian-package/actions/workflows/build.yml/badge.svg)](https://github.com/itsallcode/openfasttrace-debian-package/actions/workflows/build.yml)

## Getting the Package

Pre-built source and binary packages are available from the [GitHub releases](https://github.com/itsallcode/openfasttrace-debian-package/releases). Install the binary package with its Java runtime dependency:

```sh
sudo apt install ./openfasttrace_<version>-<package-revision>_all.deb
```

Run OpenFastTrace with:

```sh
oft --help
```

For OFT usage, including command-line options and requirement notation, see the upstream [user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide/user_guide.md).

## Building a Package

On Debian or a derived distribution, install the tools listed by the precondition check, then build a source package and its binary package for an upstream release:

```sh
./check-preconditions.sh
./create-source-package.sh <version> [package-revision]
./create-binary-package.sh <version> [package-revision]
./stage-apt-package.sh <version> [package-revision]
```

The build artifacts are placed in `out/`. The scripts download the specified OpenFastTrace source release, incorporate this repository's `debian/` packaging metadata, and build the package. `stage-apt-package.sh` validates the resulting source and binary packages, then copies them into the Debian archive pool under `apt-repository/` for inclusion in a package pull request.

## Project Information

* [OpenFastTrace upstream project](https://github.com/itsallcode/openfasttrace)
* [Upstream user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide/user_guide.md)
* [Package design](doc/design.md)
* [System requirements](doc/system_requirements.md)
* [Security policy](SECURITY.md)
* [Contributing guide](CONTRIBUTING.md)
* [Code of conduct](CODE_OF_CONDUCT.md)
