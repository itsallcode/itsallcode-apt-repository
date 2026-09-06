# itsallcode.org APT Repository

This repository contains the Debian packages published by [itsallcode.org](https://itsallcode.org). It is available as a signed APT archive at [`https://apt.itsallcode.org`](https://apt.itsallcode.org).

## Install packages

Add the itsallcode.org signing key and APT source on Debian, Ubuntu, or another Debian-derived distribution:

```sh
sudo install --directory --mode=0755 /etc/apt/keyrings
curl --fail --silent --show-error --location \
  https://apt.itsallcode.org/itsallcode-archive-keyring.asc \
  | sudo gpg --dearmor --yes --output /etc/apt/keyrings/itsallcode-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/itsallcode-archive-keyring.gpg] https://apt.itsallcode.org stable main' \
  | sudo tee /etc/apt/sources.list.d/itsallcode.list > /dev/null
sudo apt update
```

Before trusting a newly downloaded key, verify its fingerprint against the [published fingerprint](https://apt.itsallcode.org/itsallcode-archive-keyring.fingerprint).

## Available packages

### OpenFastTrace

[OpenFastTrace](https://github.com/itsallcode/openfasttrace) is an example of software distributed through this repository. It is a requirements-tracing suite that helps teams identify unimplemented requirements and obsolete product parts.

Install it with:

```sh
sudo apt install openfasttrace
```

Start it or view its command-line help with:

```sh
oft --help
```

For usage and requirement notation, see the [OpenFastTrace user guide](https://github.com/itsallcode/openfasttrace/blob/main/doc/user_guide/user_guide.md).

## Maintainers

The published archive lives in [`apt-repository/`](apt-repository/). Its [README](apt-repository/README.md) describes the archive layout and visitor-facing installation page.

The current packaging scripts build and stage OpenFastTrace packages. On Debian or a derived distribution, prepare the build environment and create a package release with:

```sh
./check-preconditions.sh
./create-source-package.sh <version> [package-revision]
./create-binary-package.sh <version> [package-revision]
./stage-apt-package.sh <version> [package-revision]
```

Build artifacts are written to `out/`; the staging script validates the package files and places them in the archive pool for review and publication.

## Project information

* [OpenFastTrace upstream project](https://github.com/itsallcode/openfasttrace)
* [Package design](doc/design.md)
* [System requirements](doc/system_requirements.md)
* [Contributing guide](CONTRIBUTING.md)
* [Security policy](SECURITY.md)
* [Code of conduct](CODE_OF_CONDUCT.md)
