import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/life_cycle/base_life_cycle.dart';

class TencentCloudCustomerEventHandler {
  /// Called when the user taps a URL link inside a message.
  ///
  /// Default behavior:
  /// - If [onTapLink] is not provided, the link will be opened
  ///   with the system's default browser.
  final void Function(String url)? onTapLink;

  /// Called after a new message has been sent.
  ///
  /// Use this to perform follow-up actions such as logging or analytics.
  MessageFunctionNullCallback didSendMessage;

  /// Called before deleting a message from the conversation history.
  ///
  /// Return `true` to confirm deletion, or `false` to cancel.
  /// This can be used to prompt the user with a confirmation dialog.
  FutureBool Function(String msgID) shouldDeleteMessage;

  /// Called before clearing the entire conversation history.
  ///
  /// Return `true` to confirm clearing, or `false` to cancel.
  /// This can be used to prompt the user with a confirmation dialog.
  FutureBool Function(String conversationID) shouldClearMessageList;

  /// Called before a message is mounted (rendered) in the message list.
  ///
  /// Return `true` to render the message, or `false` to skip rendering.
  bool Function(V2TimMessage msg) shouldMountMessage;

  /// Called before all messages are mounted (rendered) in the message list.
  ///
  /// Allows you to modify the entire message list before rendering,
  /// for example by adding, removing, or reordering messages.
  MessageListFunctionAsync shouldMountMessageList;

  TencentCloudCustomerEventHandler({
    this.onTapLink,
    this.shouldClearMessageList = DefaultLifeCycle.defaultAsyncBooleanSolution,
    this.shouldDeleteMessage = DefaultLifeCycle.defaultAsyncBooleanSolution,
    this.didSendMessage = DefaultLifeCycle.defaultNullCallbackSolution,
    this.shouldMountMessage = DefaultLifeCycle.defaultBooleanSolution,
    this.shouldMountMessageList = DefaultLifeCycle.defaultMessageListSolutionAsync,
  });

  TencentCloudCustomerEventHandler mergeWith(
      TencentCloudCustomerEventHandler? other) {
    return TencentCloudCustomerEventHandler(
      onTapLink: other?.onTapLink ?? onTapLink,
      shouldClearMessageList: other?.shouldClearMessageList ?? shouldClearMessageList,
      shouldDeleteMessage: other?.shouldDeleteMessage ?? shouldDeleteMessage,
      didSendMessage: other?.didSendMessage ?? didSendMessage,
      shouldMountMessage: other?.shouldMountMessage ?? shouldMountMessage,
      shouldMountMessageList: other?.shouldMountMessageList ?? shouldMountMessageList,
    );
  }
}