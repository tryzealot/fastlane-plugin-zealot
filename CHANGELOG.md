# 变更日志

## [未发布]

> 如下罗列的变更是还未发布的列表

## [0.7.1] (2020-12-23)

### 新增

- [action] `zealot_debug_file` 无需设置 path 和 scheme 自动获取 [gym](https://docs.fastlane.tools/actions/gym/) 的 archive path 值
- [action] `zealot_debug_file`: 支持使用给定 zip_file 上传
- [action] `zealot_debug_file`: 上传后显示解析的信息

### 变更

- [action] `zealot_debug_file`: `platform` 参数类型修改为 String

## [0.6.0] (2020-08-07)

### 新增

- [action] `zealot_version_check` 新增返回数据让外部使用

## [0.5.0] (2020-05-27)

### 新增

- [action] `zealot_sync_device` 同步时增加手机型号

## [0.4.1] (2020-05-25)

### 新增

- [action] 新增 `zealot_sync_device` 用来同步 AdHoc 的 iOS 测试设备名称
- [action] `zealot` 新增自动获取上传渠道及 CI URL 逻辑

## [0.3.0] (2020-05-21)

### 变更

- [action] `zealot_version_check` SharedValues 键 **ZEALOT_APP_VERSION_EXISTED** 改名为 **ZEALOT_VERSION_EXISTED**

### 新增

- [action] `zealot` 新增 **ZEALOT_APP_ID**, **ZEALOT_RELEASE_ID**, **ZEAALOT_ERROR_MESSAGE** SharedValues (**需 Zealot 在 2020-05-07 之后版本有效**)
- [action] `zealot_debug_file` 和 `zealot_version_check` 新增 **ZEAALOT_ERROR_MESSAGE** SharedValues

### 修复

- [action] 所有 actions 增加对网络连接失败的报错处理
- [action] 修复在执行 `fastlane action xxxx` 无法显示 Output Variables
- [action] 修复 Ruby 报的重复定义 `Fastlane::Actions::SharedValues::ZEAALOT_ERROR_MESSAGE` 错误
- [action] 由于 fastlane 依赖的 faraday 升级至 1.0+ 造成 API 变更错误

## [0.2.0] (2020-04-28)

### 新增

- [action] 新增 `zealot_debug_file` action: 上传 iOS dSYM 或 Android Proguard
- [action] `zealot` 增加自动获取 Git 分支名、Commit Hash(SHA) 和自动变更日志
- [action] `zealot` 上传支持传递自定义键值对(key-value) (**需 Zealot 在 2020-04-16 之后版本有效**)

### 修复

- 修复传参 hidden_user_token 无效

## 0.1.0 (2020-01-11)

### 新增

- 新增 `zealot` action: 上传 iOS ipa 或 Android apk
- 新增 `zealot_version_check` action: 检查 Zealot 是否已经存在版本，减少不必要的上传

## [未发布]

[未发布]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.7.0...HEAD
[0.7.0]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.3.0...v0.4.1
[0.3.0]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/getzealot/fastlane-plugin-zealot/compare/v0.1.0...v0.2.0
