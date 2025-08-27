import 'package:flutter/cupertino.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_desk_i18n_tool/tencent_desk_i18n_tool.dart';

class MessageBubbleButton extends StatelessWidget {
  final bool showAINote;
  final V2TimMessage message;

  const MessageBubbleButton({
    super.key,
    this.showAINote = false,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isSelf = message.isSelf ?? true;
    return Row(
      mainAxisAlignment: isSelf ? MainAxisAlignment.end : MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if(showAINote) Text(
          TDesk_t("该回复由AI生成，内容仅供参考"),
          style: const TextStyle(
            color: Color(0x80000000),
            fontSize: 12.0,
            fontWeight: FontWeight.w400,
            height: 22.0 / 12.0,
          ),
        )
      ],
    );
  }
}
