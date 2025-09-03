import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_state.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageStream extends StatefulWidget {
  final dynamic payload;
  final void Function(String url)? onTapLink;

  const MessageStream({
    super.key,
    this.payload,
    this.onTapLink,
  });

  @override
  State<StatefulWidget> createState() => _MessageStreamState();
}

class _MessageStreamState extends TIMState<MessageStream> {
  bool isFinish = false;

  @override
  initState() {
    super.initState();
    isFinish = widget.payload['isFinished'] == 1 ? true : false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget timBuild(BuildContext context) {
    final chunks = widget.payload['chunks'];
    final text = (chunks is List) ? chunks.join('') : '';

    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: MarkdownBody(
        data: text,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(color: Colors.black),
        ),
        onTapLink: (
          String text,
          String? href,
          String title,
        ) {
          if(widget.onTapLink != null) {
            widget.onTapLink!(href ?? "");
          } else {
            launchUrl(
              Uri.parse(href ?? ""),
              mode: LaunchMode.externalApplication,
            );
          }
        },
      ),
    );
  }
}
