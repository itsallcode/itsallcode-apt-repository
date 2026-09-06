# OpenFastTrace APT Repository

This directory is the document root published at
`https://apt.itsallcode.org/openfasttrace`.

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
committed package files. It also publishes the archive public key and the
installation instructions at this directory's root.
