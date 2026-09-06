# OpenFastTrace APT Repository

This directory is the document root published at
`https://apt.itsallcode.org/openfasttrace`. The visitor-facing installation
page is [index.html](index.html).

## Installation

Install the repository's public key in a dedicated keyring and add the signed
repository source:

```sh
sudo install --directory --mode=0755 /etc/apt/keyrings
curl --fail --silent --show-error --location \
  https://apt.itsallcode.org/openfasttrace/itsallcode-archive-keyring.asc \
  | sudo gpg --dearmor --yes --output /etc/apt/keyrings/itsallcode-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/itsallcode-archive-keyring.gpg] https://apt.itsallcode.org/openfasttrace stable main' \
  | sudo tee /etc/apt/sources.list.d/openfasttrace.list > /dev/null
sudo apt update
sudo apt install openfasttrace
```

The public key fingerprint is published at
`https://apt.itsallcode.org/openfasttrace/itsallcode-archive-keyring.fingerprint`.
Check it before trusting a newly downloaded key.

It follows the Debian archive layout:

* `pool/main/o/openfasttrace/` contains the OpenFastTrace binary and source
  package artifacts. A package pull request adds its `.deb`, `.dsc`, original
  source tarball, and Debian tarball here.
* `dists/stable/main/binary-all/` contains the generated binary package index
  for the architecture-independent OpenFastTrace package.
* `dists/stable/main/source/` contains the generated source package index.
* `dists/stable/` will contain the generated and signed `Release`,
  `InRelease`, and `Release.gpg` files.

The release workflow generates repository indexes and signatures from the
committed package files. It also publishes the archive public key and its
fingerprint at this directory's root. Merging a pull request that changes this
directory deploys the resulting repository directly to GitHub Pages.
