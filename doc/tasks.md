# Implementation Tasks for OpenFastTrace Debian Package

This task list is based on the [OpenFastTrace Debian Package Design](design.md).

## Phase 1: Environment and Project Initialization
1. - [x] Install necessary build tools: `dpkg-dev`, `debhelper`, and `devscripts` (`dsn~build-tools~1`).
2. - [x] Create the `debian/` directory structure in the project root (`dsn~debian-metadata~1`).
3. - [x] Implement `check-preconditions.sh` to verify the build environment (`dsn~precondition-check~1`, `req~precondition-check~1`).
4. - [x] Configure `.gitignore` to exclude intermediate files and build results.
5. - [x] Implement the dedicated build directory `out/` to store build artifacts (`dsn~build-directory~1`, `req~build-directory~1`).

## Phase 2: Debian Package Metadata Setup
6. - [x] Create `debian/control` with metadata: organization, maintainer, URLs (Homepage/Source), and descriptions (`dsn~debian-metadata~1`, `req~package-metadata~1`).
7. - [x] Create `debian/copyright` with GPL-3.0 license and upstream authors information (`dsn~debian-metadata~1`, `req~package-metadata~1`).
8. - [x] Create `debian/rules` as a standard build script for `dpkg-buildpackage` (`dsn~debian-metadata~1`).
9. - [x] Initialize the `debian/changelog` file with the required initial metadata (`dsn~debian-metadata~1`).
10. - [x] Update `debian/control` to include the OpenJDK 17 headless dependency (`dsn~binary-dependencies~1`, `req~binary-dependencies~1`).

## Phase 3: Source Package Automation (`create-source-package.sh`)
11. - [x] Implement command-line version argument parsing (`<major>.<minor>.<fix>`) in the build orchestration scripts (`dsn~version-input~1`).
12. - [x] Implement source code downloading from GitHub as a `.tar.gz` archive for the specified version from `https://github.com/itsallcode/openfasttrace/archive/refs/tags/<version>.tar.gz`; Test with version 4.2.2 (`dsn~source-fetching~1`).
13. - [x] Implement logic to identify relevant Markdown files in `doc/changes` within the fetched source archive (`dsn~changelog-extraction~1`).
14. - [x] Implement the conversion of Markdown content into the Debian changelog format (`dsn~changelog-extraction~1`).
15. - [x] Implement the append-only update mechanism for `debian/changelog` (`dsn~changelog-extraction~1`).
16. - [x] Automate the final assembly and creation of the Debian source package (`dsn~build-orchestration-scripts~1`).

## Phase 4: Binary Package Automation (`create-binary-package.sh`)
17. - [x] Implement `create-binary-package.sh` to trigger the binary build from the source package (`dsn~build-orchestration-scripts~1`).
18. - [x] Use `dpkg-buildpackage -us -uc -b` to ensure a reproducible binary package build (`dsn~build-reproducibility~1`).
19. - [x] Create the `oft` wrapper script and ensure it is included in the binary package (`dsn~oft-wrapper-script~1`, `req~oft-wrapper-script~1`).
20. - [x] Include the OpenFastTrace logo as application icons in the binary package: generate PNG icons in 34 sizes and scales from the square SVG icon using ImageMagick (`dsn~app-icon~1`, `req~scaled-app-icons~1`).
21. - [x] Declare the package icon as "themed" using AppStream metadata and a desktop file (`dsn~package-icon-declaration~1`, `req~package-icon-declaration~1`).
22. - [x] Declare the application screenshots in the AppStream metadata using stable raw GitHub URLs and ensure they are also downloaded and packed in the package using a static assets directory `debian/static/` to prevent cleanup by `debhelper` during build (`dsn~package-screenshots~1`, `req~package-screenshots~1`).
23. - [x] Convert the Markdown user guide to HTML and include it in the binary package (`dsn~user-guide-html~1`, `req~user-guide-html~1`).
24. - [x] Convert the Markdown user guide to a manpage and include it in the binary package (`dsn~user-guide-manpage~1`, `req~user-guide-manpage~1`).

## Phase 5: Integration Testing Automation
25. - [x] Implement `test-packaging.sh` to automate the full build process and verify the resulting files (`dsn~integration-testing~1`).
26. - [x] Verify that `test-packaging.sh` calls and validates the output of `check-preconditions.sh` (`dsn~precondition-check~1`).
27. - [x] Verify that `test-packaging.sh` correctly tests the integration of `create-source-package.sh` and `create-binary-package.sh` (`dsn~build-orchestration-scripts~1`).
28. - [x] Verify that `test-packaging.sh` checks for all expected Debian artifacts (`dsn~integration-testing~1`).
29. - [x] Verify that `test-packaging.sh` runs `shellcheck` on all shell scripts (`dsn~integration-testing~1`, `dsn~finding-free-shellcheck~1`).
30. - [x] Verify that `test-packaging.sh` validates the AppStream metadata using `appstreamcli` (`dsn~integration-testing~1`).

## Phase 6: Quality Assurance
31. - [ ] Perform a manual code review to ensure adherence to clean code principles (`dsn~clean-code-principles~1`).

## Phase 7: Final Verification
32. - [ ] Execute the full packaging workflow for a known OpenFastTrace release version.
33. - [ ] Verify the resulting `.deb` package metadata and file contents.
34. - [ ] Verify that the `debian/changelog` is correctly appended and preserves historical entries.
