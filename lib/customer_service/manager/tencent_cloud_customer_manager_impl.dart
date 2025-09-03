import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_desk_i18n_tool/language_json/strings.g.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_callback.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/data/tencent_cloud_customer_data.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_builders.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_event_handler.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/utils/tencent_cloud_customer_logger.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/utils/tencent_cloud_customer_toast.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/widgets/tencent_cloud_customer_message_container.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services_implements.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/tencentcloud_ai_desk_customer.dart';
import 'package:tencentcloud_ai_desk_customer/ui/controller/tim_uikit_chat_controller.dart';

import '../../ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';

typedef TencentCloudCustomerInit = Future<V2TimCallback> Function({
  TencentCloudCustomerConfig? config,
  required int sdkAppID,
  required String userID,
  required String userSig,
  String? nickName,
  String? avatar,
  TencentCloudCustomerMessageBuilders? builders,
  TencentCloudCustomerEventHandler? eventHandler,
});
typedef TencentCloudCustomerNavigate = V2TimCallback Function({
  TencentCloudCustomerConfig? config,
  TencentCloudCustomerMessageBuilders? builders,
  required BuildContext context,
  String? customerServiceID,
  TencentCloudDeskCustomerController? controller,
  TencentCloudCustomerEventHandler? eventHandler,
});
typedef TencentCloudCustomerDispose = Future<V2TimCallback> Function();

class TencentCloudCustomerManagerImpl {
  final TCustomerCoreServicesImpl _timCoreInstance =
      TencentCloudAIDeskCustomer.getIMUIKitInstance();
  late TencentCloudCustomerData _tencentCloudCustomerData;

  V2TimCallback? _initializedFailedRes;

  Future<V2TimCallback> init({
    required int sdkAppID,
    required String userID,
    required String userSig,
    String? nickName,
    String? avatar,
    TencentCloudCustomerConfig? config,
    TencentCloudCustomerMessageBuilders? builders,
    TencentCloudCustomerEventHandler? eventHandler,
  }) async {
    setupIMServiceLocator();
    TencentCloudCustomerLogger().init();

    _tencentCloudCustomerData = serviceLocator<TencentCloudCustomerData>();

    if (sdkAppID.toString().startsWith('1400') ||
        sdkAppID.toString().startsWith('160')) {
      _tencentCloudCustomerData.tDeskDataCenter = TDeskDataCenter.mainlandChina;
    } else {
      _tencentCloudCustomerData.tDeskDataCenter = TDeskDataCenter.international;
    }
    final initRes = await _timCoreInstance.init(
      sdkAppID: sdkAppID,
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: V2TimSDKListener(),
      language: config?.language,
      onTUIKitCallbackListener: (TIMCallback callbackValue) {
        switch (callbackValue.type) {
          case TIMCallbackType.INFO:
            // Shows the recommend text for info callback directly
            TencentCloudCustomerToast.toast(
                callbackValue.infoRecommendText ?? "");
            break;
          case TIMCallbackType.API_ERROR:
            //Prints the API error to console, and shows the error message.
            print(
                "Error from TUIKit: ${callbackValue.errorMsg}, Code: ${callbackValue.errorCode}");
            if (callbackValue.infoRecommendText != null &&
                callbackValue.infoRecommendText!.isNotEmpty) {
              TencentCloudCustomerToast.toast(
                  callbackValue.infoRecommendText ?? "");
            } else {
              TencentCloudCustomerToast.toast(
                  callbackValue.errorMsg ?? callbackValue.errorCode.toString());
            }
            break;

          case TIMCallbackType.FLUTTER_ERROR:
          default:
            // prints the stack trace to console or shows the catch error
            if (callbackValue.catchError != null) {
              TencentCloudCustomerToast.toast(
                  callbackValue.catchError.toString());
            } else {
              print(callbackValue.stackTrace);
            }
        }
      },
    );
    if (initRes ?? false) {
      final loginRes = await _timCoreInstance.login(
        userID: userID,
        userSig: userSig,
      );
      if (loginRes.code == 0) {
        _tencentCloudCustomerData.globalConfig =
            config ?? _tencentCloudCustomerData.globalConfig;
        _tencentCloudCustomerData.globalBuilders =
            builders ?? _tencentCloudCustomerData.globalBuilders;
        _tencentCloudCustomerData.globalEventHandler =
            eventHandler ?? _tencentCloudCustomerData.globalEventHandler;
        _initializedFailedRes = null;
        TencentCloudCustomerLogger().reportLogin(
          sdkAppId: sdkAppID,
          userID: userID,
          userSig: userSig,
        );
        if (nickName != null || avatar != null) {
          V2TimUserFullInfo userInfo = V2TimUserFullInfo(
            nickName: nickName,
            faceUrl: avatar,
          );
          _timCoreInstance.setSelfInfo(userFullInfo: userInfo);
        }
      } else {
        _initializedFailedRes = loginRes;
      }
      return loginRes;
    } else {
      _initializedFailedRes = V2TimCallback(
        code: -1,
        desc: 'Init Failed',
      );
      return _initializedFailedRes!;
    }
  }

  V2TimCallback navigate({
    required BuildContext context,
    String? customerServiceID,
    TencentCloudCustomerConfig? config,
    TencentCloudCustomerMessageBuilders? builders,
    TencentCloudDeskCustomerController? controller,
    TencentCloudCustomerEventHandler? eventHandler,
  }) {
    if (_initializedFailedRes != null) {
      return _initializedFailedRes!;
    }
    TencentCloudCustomerToast.init(context);
    final targetConfig =
        _tencentCloudCustomerData.globalConfig.mergeWith(config);
    final targetBuilders =
        _tencentCloudCustomerData.globalBuilders.mergeWith(builders);
    final targetEventHandler =
        _tencentCloudCustomerData.globalEventHandler.mergeWith(eventHandler);
    if (config?.language != null) {
      TDeskI18nUtils(null, languageLocaleToString[config?.language]);
    }
    final String id = customerServiceID ?? "@customer_service_account";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TencentCloudCustomerMessageContainer(
          customerServiceUserID: id,
          config: targetConfig,
          builder: targetBuilders,
          controller: controller ?? TencentCloudDeskCustomerController(),
          eventHandler: targetEventHandler,
        ),
      ),
    );
    return V2TimCallback(
      code: 0,
      desc: '',
    );
  }

  Future<V2TimCallback> dispose() {
    _initializedFailedRes = null;
    return _timCoreInstance.logout();
  }
}
