import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_qucik_message.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';

typedef DeskHeaderBuilder = Widget Function({
  required V2TimConversation conversation,
  String? targetTypingIndicator,
});

typedef QuickMessagesBuilder = Widget Function({
  required List<TencentCloudCustomerQuickMessage>? quickMessages,
});

typedef ChatDeskBotMessagesBuilder = Widget? Function({
  required V2TimMessage message,
  required bool isShowJump,
  required VoidCallback clearJump,
});

class TencentCloudCustomerMessageBuilders {
  /// 用于自定义聊天界面顶部区域的构建方法，替换默认的顶部 UI。
  ///
  /// 提供的参数：
  /// - [V2TimConversation conversation]：当前客服会话的完整信息，例如客服号 ID、客服昵称、客服头像等。
  /// - [String? targetTypingIndicator]：如果客服坐席正在输入，这里会传入输入中的提示文本，否则为 null。
  ///
  /// ---
  ///
  /// Builder function for customizing the chat header area, overriding the default header UI.
  ///
  /// Parameters:
  /// - [V2TimConversation conversation]: Contains the current customer service session information,
  ///   such as service ID, nickname, and avatar.
  /// - [String? targetTypingIndicator]: A typing indicator string when the agent is typing, or null if idle.
  final DeskHeaderBuilder? headerBuilder;

  /// 用于自定义快捷回复消息区域，显示在底部输入框的上方。
  ///
  /// 提供的参数：
  /// - [List<TencentCloudCustomerQuickMessage>? quickMessages]：当前可供选择的快捷消息列表，
  ///   开发者可以自定义 UI 来展示和发送这些快捷语。
  ///
  /// ---
  ///
  /// Builder function for customizing the quick messages section,
  /// which is displayed above the bottom input box.
  ///
  /// Parameters:
  /// - [List<TencentCloudCustomerQuickMessage>? quickMessages]: The available quick message list,
  ///   allowing developers to design their own UI for displaying and sending them.
  final QuickMessagesBuilder? quickMessagesBuilder;

  /// 用于自定义“小舌头”组件，显示在消息列表右下角，
  /// 常用于提示未读消息数量、返回消息底部等功能。
  ///
  /// ---
  ///
  /// Builder function for customizing the "tongue" item,
  /// displayed at the bottom-right corner of the message list.
  /// Typically used for showing new message counts or a shortcut to scroll back to the latest message.
  final DeskTongueItemBuilder? tongueItemBuilder;

  /// 用于自定义消息内容区域，包括各种类型的消息（文本、图片、视频等），
  /// 以及每一行消息的整体布局。
  ///
  /// 注意：
  /// - 请不要通过重写 [regularMessageItemBuilder] 来修改 Desk Chatbot 消息的渲染。
  /// - [regularMessageItemBuilder] 仅用于自定义“普通消息”（自定义消息类型、文本、图片、视频等）。
  /// - 如果需要修改 Desk Chatbot 消息，请使用 [deskChatBotMessagesBuilder]。
  ///
  /// ---
  ///
  /// Builder for customizing the chat message area, including different message types
  /// (text, image, video, etc.) and the overall row layout for each message.
  ///
  /// Note:
  /// - Do **not** override [regularMessageItemBuilder] to modify Desk Chatbot messages.
  /// - [regularMessageItemBuilder] is only for customizing “regular messages”
  ///   (custom messages, text, images, videos, etc.).
  /// - To customize Desk Chatbot messages, use [deskChatBotMessagesBuilder] instead.
  final DeskMessageItemBuilder? regularMessageItemBuilder;

  /// 用于修改 Desk Chatbot 消息的渲染逻辑。
  ///
  /// - 请根据消息 [customElem] 的 `data` 字段来判断消息类型。
  ///   当消息为 Chatbot 类型时，`data` 是一个 JSON 字符串。
  /// - 其中的 `src` 字段会标识消息类型，例如“评价”、“卡片”、“分支”等。
  /// - 如果需要自定义渲染，请返回一个 Widget。
  /// - 如果不需要自定义渲染，返回 `null` 即可使用默认渲染逻辑。
  ///
  /// ---
  ///
  /// Builder for customizing Desk Chatbot messages.
  ///
  /// - Inspect the `data` field inside the message’s [customElem] to determine the type.
  ///   For Chatbot messages, `data` is a JSON string.
  /// - The `src` field specifies the message type, e.g. “evaluation”, “card”, “branch”, etc.
  /// - Return a custom widget if you want to override the rendering.
  /// - Return `null` to fall back to the default rendering.
  final ChatDeskBotMessagesBuilder? deskChatBotMessagesBuilder;

  /// 用于自定义会话双方的头像展示组件, 替换默认头像显示，例如加载自定义头像源、添加边框、状态标识等。
  ///
  /// 提供的参数：
  /// - [BuildContext context]：当前的构建上下文。
  /// - [V2TimMessage message]：消息对象，包含了消息发送者的身份信息，可用于区分用户和客服。
  ///
  /// ---
  ///
  /// Builder function for customizing the avatar widget for both participants in the conversation, to override the default avatar.
  ///
  /// Parameters:
  /// - [BuildContext context]: The current build context.
  /// - [V2TimMessage message]: The message object containing the sender information, useful for distinguishing between customer and agent.
  final Widget Function(BuildContext context, V2TimMessage message)? userAvatarBuilder;

  /// 用于自定义底部输入框区域，包括消息输入与发送功能。
  ///
  /// 提供的参数：
  /// - [BuildContext context]：当前的构建上下文。
  ///
  /// ---
  ///
  /// Builder function for customizing the bottom message input field.
  ///
  /// Parameters:
  /// - [BuildContext context]: The current build context.
  final Widget Function(BuildContext context)? messageInputBuilder;

  TencentCloudCustomerMessageBuilders({
    this.headerBuilder,
    this.quickMessagesBuilder,
    this.tongueItemBuilder,
    this.regularMessageItemBuilder,
    this.deskChatBotMessagesBuilder,
    this.userAvatarBuilder,
    this.messageInputBuilder,
  });

  TencentCloudCustomerMessageBuilders mergeWith(
      TencentCloudCustomerMessageBuilders? other) {
    return TencentCloudCustomerMessageBuilders(
      headerBuilder: other?.headerBuilder ?? headerBuilder,
      quickMessagesBuilder: other?.quickMessagesBuilder ?? quickMessagesBuilder,
      tongueItemBuilder: other?.tongueItemBuilder ?? tongueItemBuilder,
      regularMessageItemBuilder: other?.regularMessageItemBuilder ?? regularMessageItemBuilder,
      deskChatBotMessagesBuilder:
          other?.deskChatBotMessagesBuilder ?? deskChatBotMessagesBuilder,
      userAvatarBuilder: other?.userAvatarBuilder ?? userAvatarBuilder,
      messageInputBuilder: other?.messageInputBuilder ?? messageInputBuilder,
    );
  }
}
