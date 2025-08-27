import 'package:flutter/cupertino.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/manager/tencent_cloud_customer_manager_impl.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_builders.dart';
import 'package:tencentcloud_ai_desk_customer/tencentcloud_ai_desk_customer.dart';
import 'package:tencentcloud_ai_desk_customer/ui/controller/tim_uikit_chat_controller.dart';

class TencentCloudCustomerManager {
  static final TencentCloudCustomerManager _instance = TencentCloudCustomerManager._internal();

  TencentCloudCustomerManager._internal();

  factory TencentCloudCustomerManager() {
    return _instance;
  }

  final TencentCloudCustomerManagerImpl _tencentCloudCustomerManagerImpl = TencentCloudCustomerManagerImpl();

  Future<V2TimCallback> init({
    required int sdkAppID,
    required String userID,
    required String userSig,
    String? nickName,
    String? avatar,
    TencentCloudCustomerConfig? config,
    TencentCloudCustomerMessageBuilders? builders,
  }) async {
    return _tencentCloudCustomerManagerImpl.init(
      sdkAppID: sdkAppID,
      userID: userID,
      userSig: userSig,
      nickName: nickName,
      avatar: avatar,
      config: config,
      builders: builders,
    );
  }

  V2TimCallback navigate({
    required BuildContext context,
    String? customerServiceID,
    TencentCloudCustomerConfig? config,
    TencentCloudCustomerMessageBuilders? builders,
    TencentCloudDeskCustomerController? controller,
  }) {
    return _tencentCloudCustomerManagerImpl.navigate(
      customerServiceID: customerServiceID,
      config: config,
      context: context,
      builders: builders,
      controller: controller,
    );
  }

  Future<V2TimCallback> dispose(){
    return _tencentCloudCustomerManagerImpl.dispose();
  }
}
