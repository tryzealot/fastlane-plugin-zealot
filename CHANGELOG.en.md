# Changelog

[中文](CHANGELOG.md)

## [Unreleased]

> The following changes have not been released yet.

## [1.0.1] (2026-09-03)

### Fixed

- [action] Fixed compatibility with Faraday 1.0 and 2.0

## [1.0.0] (2025-05-30)

The first stable release!

## [0.7.1] (2020-12-23)

### Added

- [action] `zealot_debug_file` can automatically obtain the archive path from the [gym](https://docs.fastlane.tools/actions/gym/) action without setting `path` or `scheme`
- [action] `zealot_debug_file`: support uploading a specified `zip_file`
- [action] `zealot_debug_file`: display parsed information after uploading

### Changed

- [action] Changed the `platform` parameter type to String

## [0.6.0] (2020-08-07)

### Added

- [action] `zealot_version_check` now returns data for external use

## [0.5.0] (2020-05-27)

### Added

- [action] Include the phone model when synchronizing devices with `zealot_sync_device`

## [0.4.1] (2020-05-25)

### Added

- [action] Added `zealot_sync_device` to synchronize the names of iOS Ad Hoc test devices
- [action] `zealot` now automatically obtains the upload channel and CI URL

## [0.3.0] (2020-05-21)

### Changed

- [action] Renamed the SharedValues key **ZEALOT_APP_VERSION_EXISTED** to **ZEALOT_VERSION_EXISTED** in `zealot_version_check`

### Added

- [action] Added **ZEALOT_APP_ID**, **ZEALOT_RELEASE_ID**, and **ZEAALOT_ERROR_MESSAGE** SharedValues to `zealot` (**requires Zealot version 2020-05-07 or later**)
- [action] Added **ZEAALOT_ERROR_MESSAGE** SharedValues to `zealot_debug_file` and `zealot_version_check`

### Fixed

- [action] Added error handling for network connection failures to all actions
- [action] Fixed Output Variables not being displayed when running `fastlane action xxxx`
- [action] Fixed the duplicate definition error for `Fastlane::Actions::SharedValues::ZEAALOT_ERROR_MESSAGE` reported by Ruby
- [action] Fixed API change errors caused by the Faraday dependency used by fastlane upgrading to 1.0+

## [0.2.0] (2020-04-28)

### Added

- [action] Added the `zealot_debug_file` action to upload iOS dSYM or Android Proguard files
- [action] `zealot` now automatically obtains the Git branch name, commit hash (SHA), and changelog
- [action] `zealot` supports passing custom key-value pairs (**requires Zealot version 2020-04-16 or later**)

### Fixed

- Fixed `hidden_user_token` not working when passed as an argument

## 0.1.0 (2020-01-11)

### Added

- Added the `zealot` action to upload iOS ipa or Android apk files
- Added the `zealot_version_check` action to check whether a version already exists in Zealot and avoid unnecessary uploads

## [Unreleased]

[Unreleased]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.8.0...v1.0.0
[0.8.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.7.1...v0.8.0
[0.7.1]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.3.0...v0.4.1
[0.3.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/tryzealot/fastlane-plugin-zealot/compare/v0.1.0...v0.2.0
