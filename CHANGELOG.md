
# 1.4.0

## Breaking Changes

- Upgraded the underlying `tencent_cloud_chat_sdk` to version **^8.6.7019+2**, which is **not backward compatible** with versions 8.5 and earlier.
- Refactored the file import structure in the `tencent_cloud_chat_sdk` package.

## Optimized

- Made the `customerServiceID` parameter in `navigate` optional, with a default fallback to `"@customer_service_account"` when not provided.

# 1.3.1

## Added

- Added support for fixed options in branch messages.

# 1.3.0

## Breaking Changes

- Upgraded the underlying `tencent_cloud_chat_sdk` to version **8.5**, which is **not backward compatible** with versions 8.4 and earlier.
- If your project also utilizes other Tencent packages such as `tencent_cloud_chat_uikit`, ensure that their underlying `tencent_cloud_chat_sdk` dependency is equaled to version **8.5** to maintain compatibility.
- You can verify the SDK version in your project by checking the `pubspec.lock` file.

# 1.2.4

## Fixed

- Fixed some bugs.

# 1.2.3

## Fixed

- Resolved an issue where a new conversation would automatically start after the previous session ended.

## Optimized

- Improved the layout of evaluation messages.
- Improved the layout for quoted messages within the Workspace display.

# 1.2.2

## Added

- Added a new animated loading indicator for the bot’s "thinking" state.

# 1.2.1

## Fixed

- Addressed build failures on Flutter 3.27.1.
- Resolved video playback and recording issues on Huawei P30.

## Optimized

- Refined the UI for group notification display.
- Improved the layout of the read receipt page.
- Enhanced text wrapping and truncation for lengthy tip messages.

# 1.2.0

## Breaking Changes

- Renamed package from `tencent_cloud_customer` to `tencentcloud_ai_desk_customer`.
- Renamed class from `TencentCloudCustomer` to `TencentCloudAIDeskCustomer`.

## Added

- Added support for the Indonesian language.
- Introduced a `language` option in `TencentCloudCustomerConfig` for explicit language selection.

## Fixed

- Fixed a bug in streamed messages causing inconsistent real-time output.

# 1.1.0

## Added

- Introduced `dispose` method to properly clean up resources before logging out or switching accounts.

# 1.0.0

First release of the Customer Service UIKit.

## Initial Release

- Added `init` method to initialize the Customer UIKit.
- Added `navigate` method to open the customer service chat interface.
