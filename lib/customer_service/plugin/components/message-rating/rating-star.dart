import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/common/utils.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_state.dart';


class RatingStar extends StatefulWidget {
  final dynamic payload;
  final Function onSubmitRating;
  const RatingStar({super.key, this.payload, required this.onSubmitRating});

  @override
  State<StatefulWidget> createState() => _RatingStarState();
}

class _RatingStarState extends TIMState<RatingStar> {
  int selectIndex = -1;
  bool hasReply = false;
  bool isExpired = false;
  Future<V2TimMsgCreateInfoResult?> submitRating({required data}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .createCustomMessage(
            data: json.encode({
          'src': CUSTOM_MESSAGE_SRC.MENU_SELECTED,
          'menuSelected': data,
          'customerServicePlugin': 0,
        }));
    if (res.code == 0) {
      final messageResult = res.data;
      V2TimMessage? messageInfo = messageResult!.messageInfo;
      if (!kIsWeb && (Platform.isMacOS || Platform.isWindows)) {
        messageInfo?.id = messageResult.id;
      }
      widget.onSubmitRating(messageInfo: messageInfo, onlineUserOnly: true);
      return messageResult;
    }
    return null;
  }

  @override
  Widget timBuild(BuildContext context) {
    String header = widget.payload['head'];
    String tail = widget.payload['tail'];
    String sessionId = widget.payload['sessionId'];
    int expireTime = widget.payload['expireTime'];
    final List menu = widget.payload['menu'];
    DateTime now = DateTime.now();
    int timestamp = now.millisecondsSinceEpoch;
    int timestampInSeconds = timestamp ~/ 1000;
    if (expireTime < timestampInSeconds) {
      isExpired = true;
    }


    try {
      if (widget.payload['selected'] != null) {
        for (int i = 0; i < menu.length; i++) {
          if (menu[i]['id'] == widget.payload['selected']['id']) {
            hasReply = true;
            selectIndex = i;
          }
        }
      }
    } catch (e) {}

    return Column(children: [
      Container(
        child: Text(
          header,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(60, 20, 60, 21),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.white, width: 0),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: Column(children: [
          Container(
            child: Text(header),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
          ),
          Wrap(
              spacing: 8.0, // 主轴(水平)方向间距
              runSpacing: 4.0, // 纵轴（垂直）方向间距
              alignment: WrapAlignment.start, //沿主轴方向居中
              children: menu.asMap().entries.map((e) {
                return GestureDetector(
                    child: e.key > selectIndex
                        ? const Image(
                            image: AssetImage(
                              "lib/customer_service/assets/starLine.png",
                              package: "tencentcloud_ai_desk_customer",
                            ),
                            width: 24.0)
                        : const Image(
                            image: AssetImage(
                              "lib/customer_service/assets/star.png",
                              package: "tencentcloud_ai_desk_customer",
                            ),
                            width: 24.0),
                    onTap: () {
                      setState(() {
                        selectIndex = e.key;
                      });
                    });
              }).toList()),
          const Padding(padding: EdgeInsets.only(top: 10)),
          if(selectIndex != -1) Text(menu[selectIndex]['content']),
          Container(
            child: ElevatedButton(
              style: (hasReply || isExpired)
                  ? ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.grey),
                    )
                  : null,
              child: Text(TDesk_t("确认")),
              onPressed: () {
                if (hasReply || isExpired) {
                  return;
                }
                DateTime now = DateTime.now();
                int timestamp = now.millisecondsSinceEpoch;
                int timestampInSeconds = timestamp ~/ 1000;
                if (expireTime < timestampInSeconds) {
                  setState(() {
                    hasReply = true;
                  });
                  return;
                }
                setState(() {
                  hasReply = true;
                });
                submitRating(data: {
                  'id': menu[selectIndex]['id'],
                  "content": menu[selectIndex]['content'],
                  "sessionId": sessionId
                });
              },
            ),
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
          ),
        ]),
      ),
      hasReply
          ? Text(
              tail,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            )
          : Container(),
    ]);
  }
}
