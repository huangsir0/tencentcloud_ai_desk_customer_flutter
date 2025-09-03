import 'package:flutter/cupertino.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_config.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_builders.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_event_handler.dart';

enum TDeskDataCenter {
  mainlandChina,
  international,
}

class TencentCloudCustomerData extends ChangeNotifier {
  TencentCloudCustomerConfig globalConfig = TencentCloudCustomerConfig();
  TencentCloudCustomerMessageBuilders globalBuilders = TencentCloudCustomerMessageBuilders();
  TencentCloudCustomerEventHandler globalEventHandler = TencentCloudCustomerEventHandler();

  TDeskDataCenter tDeskDataCenter = TDeskDataCenter.international;
}
