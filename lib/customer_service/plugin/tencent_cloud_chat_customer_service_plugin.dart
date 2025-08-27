import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tencent_cloud_chat_sdk/manager/v2_tim_manager.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_custom_elem.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_desk_i18n_tool/language_json/strings.g.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/data/tencent_cloud_customer_data.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/common/utils.dart';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/tencentcloud_ai_desk_customer.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/tim_uikit_cloud_custom_data.dart';


class TencentCloudChatCustomerServicePlugin {
  static final V2TIMManager imManager = TencentImSDKPlugin.v2TIMManager;

  static late String currentUser;
  static bool hasInited = false;
  static List<String> srcWhiteList = [
    CUSTOM_MESSAGE_SRC.MENU,
    CUSTOM_MESSAGE_SRC.FROM_INPUT,
    CUSTOM_MESSAGE_SRC.PRODUCT_CARD,
    CUSTOM_MESSAGE_SRC.BRANCH,
    CUSTOM_MESSAGE_SRC.ORDER_CARD,
    CUSTOM_MESSAGE_SRC.ROBOT_WELCOME_CARD,
    CUSTOM_MESSAGE_SRC.RICH_TEXT,
    CUSTOM_MESSAGE_SRC.STREAM_TEXT,
    CUSTOM_MESSAGE_SRC.BRANCH_MESSAGE,
    CUSTOM_MESSAGE_SRC.FORM_SAVE,
    CUSTOM_MESSAGE_SRC.MODEL_THINKING,
    CUSTOM_MESSAGE_SRC.TIMEOUT_REMINDER,
  ];
  static List<String> aiNoteMessageTypeList = [
    'fallback',
    'faq',
    'aiReply',
  ];
  static List<String> rowWhiteList = [
    CUSTOM_MESSAGE_SRC.MENU,
  ];
  static List<String> typingWhiteList = [
    CUSTOM_MESSAGE_SRC.TYPING_STATE,
  ];


  static initPlugin() async {
    final res = await TencentImSDKPlugin.v2TIMManager.checkAbility();
    if (res.code == 0) {
      hasInited = true;
      return;
    }
    hasInited = false;
    return;
  }

  static getCustomerServiceInfo(customerServiceUserList) async {
    List<V2TimUserFullInfo> customerServiceInfoList = [];
    V2TimValueCallback<List<V2TimUserFullInfo>> getUsersInfoRes =
        await TencentImSDKPlugin.v2TIMManager
            .getUsersInfo(userIDList: customerServiceUserList); //需要查询的用户id列表
    if (getUsersInfoRes.code == 0) {
      // 查询成功
      getUsersInfoRes.data?.forEach((element) {
        customerServiceInfoList.add(element);
      });
    }
    return customerServiceInfoList;
  }

  static bool isCustomerServiceMessage(V2TimMessage message) {
    bool isCustomerService = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData["customerServicePlugin"] == 0) {
            isCustomerService = true;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isCustomerService;
  }

  static bool isCustomerServiceMessageInvisible(V2TimMessage message) {
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);

          if (!srcWhiteList.contains(mapData["src"])) {
            return true;
          }

          if (mapData["src"] == CUSTOM_MESSAGE_SRC.MODEL_THINKING) {
            int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            if (mapData["thinkingStatus"] == 1 || (currentTime - message.timestamp! > 60)) {
              return true;
            }
          }
        } catch (err) {
          return false;
        }
      }
    }
    return false;
  }

  static bool canShowAINote(V2TimMessage message) {
    String? custom = message.cloudCustomData;

    if (TencentDeskUtils.checkString(custom) != null) {
      Map messageCloudCustomData;
      try {
        messageCloudCustomData = json.decode(message.cloudCustomData ?? "{}");
        final String deviceLocale = TDesk_getCurrentDeviceLocale();
        return aiNoteMessageTypeList.contains(messageCloudCustomData["messageType"] ?? "") && messageCloudCustomData["role"] == 'robot' && (deviceLocale.contains("zh-Hans") || deviceLocale.contains("en"));
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }
  }

  static bool isCanSendEvaluate(V2TimMessage message) {
    bool isCanSendEvaluate = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData['content']['menuSendRuleFlag'] >> 2 == 1) {
            isCanSendEvaluate = true;
          } else {
            isCanSendEvaluate = false;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isCanSendEvaluate;
  }

  static bool isCanSendEvaluateMessage(V2TimMessage message) {
    bool isCanSendEvaluateMessage = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData["src"] == CUSTOM_MESSAGE_SRC.SATISFACTION_CON) {
            isCanSendEvaluateMessage = true;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isCanSendEvaluateMessage;
  }

  static bool isRowCustomerServiceMessage(V2TimMessage message) {
    bool isRow = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (rowWhiteList.contains(mapData["src"])) {
            isRow = true;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isRow;
  }

  static bool isTypingCustomerServiceMessage(V2TimMessage message) {
    bool isTyping = false;
    V2TimCustomElem? custom = message.customElem;
    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (typingWhiteList.contains(mapData["src"])) {
            isTyping = true;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isTyping;
  }

  static void getEvaluateMessage(Function sendMessage) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createCustomMessage(
            data: json.encode({
          'src': CUSTOM_MESSAGE_SRC.USER_SATISFACTION,
          'customerServicePlugin': 0,
        }));
    if (res.code == 0) {
      final messageResult = res.data;
      V2TimMessage? messageInfo = messageResult!.messageInfo;
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        messageInfo?.id = messageResult.id;
      }
      sendMessage(messageInfo: messageInfo, onlineUserOnly: true);
    }
  }

  static void sendCustomerServiceStartMessage(Function sendMessage, String language) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createCustomMessage(
            data: json.encode({
          'src': CUSTOM_MESSAGE_SRC.MINI_APP_AUTO,
          'customerServicePlugin': 0,
          "triggeredContent": {"language": language}
        }));
    if (res.code == 0) {
      final messageResult = res.data;
      V2TimMessage? messageInfo = messageResult!.messageInfo;
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        messageInfo?.id = messageResult.id;
      }
      sendMessage(messageInfo: messageInfo, onlineUserOnly: true);
    }
  }

  static void sendCustomerServiceEndSessionMessage(Function sendMessage) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createCustomMessage(
            data: json.encode({
          'src': CUSTOM_MESSAGE_SRC.USER_ENDSESSION,
          'customerServicePlugin': 0,
        }));
    if (res.code == 0) {
      final messageResult = res.data;
      V2TimMessage? messageInfo = messageResult!.messageInfo;
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        messageInfo?.id = messageResult.id;
      }
      sendMessage(messageInfo: messageInfo, onlineUserOnly: true);
    }
  }

  static bool isInSession(V2TimMessage message) {
    bool isInSession = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData['content']['content'] == "inSeat") {
            isInSession = true;
          } else {
            isInSession = false;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isInSession;
  }

  static bool isInSessionMessage(V2TimMessage message) {
    bool isInSessionMessage = false;
    V2TimCustomElem? custom = message.customElem;

    if (custom != null) {
      String? data = custom.data;
      if (data != null && data.isNotEmpty) {
        try {
          Map<String, dynamic> mapData = json.decode(data);
          if (mapData["src"] == CUSTOM_MESSAGE_SRC.USER_IN_SESSION) {
            isInSessionMessage = true;
          }
        } catch (err) {
          // err
        }
      }
    }
    return isInSessionMessage;
  }
}
