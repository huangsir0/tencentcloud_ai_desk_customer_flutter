import 'package:flutter/material.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_state.dart';

import 'package:url_launcher/url_launcher.dart';

class MessageProductCard extends StatefulWidget {
  final dynamic payload;
  final void Function(String url)? onTapLink;

  const MessageProductCard({
    super.key,
    this.payload,
    this.onTapLink,
  });

  @override
  State<StatefulWidget> createState() => _MessageProductCardState();
}

class _MessageProductCardState extends TIMState<MessageProductCard> {
  @override
  Widget timBuild(BuildContext context) {
    String pic = widget.payload['pic'];
    String header = widget.payload['header'];
    String desc = widget.payload['desc'];
    final Uri _url = Uri.parse(widget.payload['url']);

    Future<void> _launchUrl() async {
      if (widget.onTapLink != null) {
        widget.onTapLink!(widget.payload['url']);
      } else {
        if (!await launchUrl(
          _url,
          mode: LaunchMode.externalApplication,
        )) {
          throw Exception('Could not launch $_url');
        }
      }
    }

    return GestureDetector(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 230),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(
              pic,
              height: 88,
              width: 88.0,
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  alignment: Alignment.center,
                  child: const Image(
                      image: AssetImage(
                        "lib/customer_service/assets/fail.png",
                        package: "tencentcloud_ai_desk_customer",
                      ),
                      height: 88,
                      width: 88.0),
                  width: 88,
                  height: 88,
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              constraints: const BoxConstraints(minHeight: 88),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style: const TextStyle(fontSize: 12),
                    header,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    style:
                        const TextStyle(fontSize: 16, color: Colors.deepOrange),
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          )
        ]),
      ),
      onTap: _launchUrl,
    );
  }
}
