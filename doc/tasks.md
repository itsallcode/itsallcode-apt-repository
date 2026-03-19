# Implementation Tasks for OpenFastTrace Debian Package

This task list is based on the [OpenFastTrace Debian Package Design](design.md).

## Phase 1: Environment and Project Initialization
1. - [x] Install necessary build tools: `dpkg-dev`, `debhelper`, and `devscripts` (`dsn~build-tools~1`).
2. - [x] Create the `debian/` directory structure in the project root (`dsn~debian-metadata~1`).
3. - [x] Implement `check-preconditions.sh` to verify the build environment (`dsn~precondition-check~1`, `req~precondition-check~1`).

## Phase 2: Debian Package Metadata Setup
4. - [x] Create `debian/control` with metadata: organization, maintainer, URLs (Homepage/Source), and descriptions (`dsn~debian-metadata~1`, `req~package-metadata~1`).
5. - [x] Create `debian/copyright` with GPL-3.0 license and upstream authors information (`dsn~debian-metadata~1`, `req~package-metadata~1`).
6. - [x] Create `debian/rules` as a standard build script for `dpkg-buildpackage` (`dsn~debian-metadata~1`).
7. - [x] Initialize the `debian/changelog` file with the required initial metadata (`dsn~debian-metadata~1`).

## Phase 3: Source Package Automation (`create-source-package.sh`)
8. - [ ] Implement command-line version argument parsing (`<major>.<minor>.<fix>`) in the build orchestration scripts (`dsn~version-input~1`).
9. - [ ] Implement source code downloading from GitHub as a `.tar.gz` archive for the specified version (`dsn~source-fetching~1`).
10. - [ ] Implement logic to identify relevant Markdown files in `doc/changes` within the fetched source archive (`dsn~changelog-extraction~1`).
11. - [ ] Implement the conversion of Markdown content into the Debian changelog format (`dsn~changelog-extraction~1`).
12. - [ ] Implement the append-only update mechanism for `debian/changelog` (`dsn~changelog-extraction~1`).
13. - [ ] Automate the final assembly and creation of the Debian source package (`dsn~build-orchestration-scripts~1`).

## Phase 4: Binary Package Automation (`create-binary-package.sh`)
14. - [ ] Implement `create-binary-package.sh` to trigger the binary build from the source package (`dsn~build-orchestration-scripts~1`).
15. - [ ] Use `dpkg-buildpackage -us -uc -b` to ensure a reproducible binary package build (`dsn~build-reproducibility~1`).

## Phase 5: Integration Testing Automation
16. - [ ] Implement `test-packaging.sh` to automate the full build process and verify the resulting files (`dsn~integration-testing~1`).
17. - [ ] Verify that `test-packaging.sh` calls and validates the output of `check-preconditions.sh` (`dsn~precondition-check~1`).
18. - [ ] Verify that `test-packaging.sh` correctly tests the integration of `create-source-package.sh` and `create-binary-package.sh` (`dsn~build-orchestration-scripts~1`).
19. - [ ] Verify that `test-packaging.sh` checks for all expected Debian artifacts (`dsn~integration-testing~1`).
20. - [ ] Verify that `test-packaging.sh` runs `shellcheck` on all shell scripts (`dsn~integration-testing~1`, `dsn~finding-free-shellcheck~1`).

## Phase 6: Quality Assurance
21. - [ ] Perform a manual code review to ensure adherence to clean code principles (`dsn~clean-code-principles~1`).

## Phase 7: Final Verification
22. - [ ] Execute the full packaging workflow for a known OpenFastTrace release version.
23. - [ ] Verify the resulting `.deb` package metadata and file contents.
24. - [ ] Verify that the `debian/changelog` is correctly appended and preserves historical entries.
