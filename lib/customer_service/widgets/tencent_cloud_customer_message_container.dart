import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/data/tencent_cloud_customer_data.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_builders.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_message_event_handler.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/components/message-bubble-button.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/components/message-customer-service.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/plugin/tencent_cloud_chat_customer_service_plugin.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_base.dart';
import 'package:tencentcloud_ai_desk_customer/base_widgets/tim_ui_kit_state.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/life_cycle/chat_life_cycle.dart';
import 'package:tencentcloud_ai_desk_customer/business_logic/view_models/tui_conversation_view_model.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/model/tencent_cloud_customer_qucik_message.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/widgets/tencent_cloud_customer_message_header.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/widgets/tencent_cloud_customer_message_quick_message.dart';
import 'package:tencentcloud_ai_desk_customer/customer_service/widgets/tencent_cloud_customer_message_tongue_item.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/conversation/conversation_services.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/core/core_services.dart';
import 'package:tencentcloud_ai_desk_customer/data_services/services_locatar.dart';
import 'package:tencentcloud_ai_desk_customer/tencentcloud_ai_desk_customer.dart';
import 'package:tencentcloud_ai_desk_customer/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKItMessageList/TIMUIKitTongue/tim_uikit_chat_history_message_list_tongue.dart';
import 'package:tencent_desk_i18n_tool/language_json/strings.g.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_chat_history_message_list_item.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_more_panel.dart';
import 'package:tencentcloud_ai_desk_customer/ui/views/TIMUIKitChat/tim_uikit_chat_config.dart';

class TencentCloudCustomerMessageContainer extends StatefulWidget {
  final String customerServiceUserID;
  final TencentCloudCustomerConfig config;
  final TencentCloudCustomerMessageBuilders builder;
  final TencentCloudDeskCustomerController controller;
  final TencentCloudCustomerEventHandler eventHandler;

  const TencentCloudCustomerMessageContainer({
    super.key,
    required this.customerServiceUserID,
    required this.config,
    required this.builder,
    required this.controller,
    required this.eventHandler,
  });

  @override
  State<TencentCloudCustomerMessageContainer> createState() =>
      _TencentCloudCustomerMessageContainerState();
}

class _TencentCloudCustomerMessageContainerState
    extends TIMUIKitState<TencentCloudCustomerMessageContainer> {
  final TCustomerConversationViewModel _conversationViewModel =
      serviceLocator<TCustomerConversationViewModel>();
  final TCustomerConversationService _conversationService =
      serviceLocator<TCustomerConversationService>();
  final TencentCloudCustomerData _tencentCloudCustomerData =
      serviceLocator<TencentCloudCustomerData>();

  V2TimConversation? _customerServiceConversation;
  String? _customerServiceTyping;
  List<TencentCloudCustomerQuickMessage> _quickMessages = [];

  @override
  void initState() {
    super.initState();
    _loadQuickMessages();
    _loadConversation();
  }

  @override
  void didUpdateWidget(TencentCloudCustomerMessageContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerServiceUserID != widget.customerServiceUserID &&
        TencentDeskUtils.checkString(widget.customerServiceUserID) != null) {
      _loadConversation();
    }
  }

  _sendStartMessage(int times) {
    final TDeskAppLocale language = widget.config.language ??
        TDesk_getCurrentDeviceLocaleInLocale(
            _tencentCloudCustomerData.tDeskDataCenter ==
                    TDeskDataCenter.mainlandChina
                ? TDeskAppLocale.zhHans
                : TDeskAppLocale.en);
    Future.delayed(const Duration(milliseconds: 50), () {
      try {
        TencentCloudChatCustomerServicePlugin.sendCustomerServiceStartMessage(
            widget.controller.sendMessage,
            languageLocaleToDeskString[language] ?? "en");
      } catch (e) {
        if (times < 4) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _sendStartMessage(times++);
          });
        }
      }
    });
  }

  _loadQuickMessages() {
    final config = widget.config;
    if (config.showTransferToHumanButton ?? true) {
      _quickMessages.add(
        TencentCloudCustomerQuickMessage(
          label: TDesk_t("人工服务"),
          icon: SvgPicture.asset(
            "lib/customer_service/assets/human_service.svg",
            package: 'tencentcloud_ai_desk_customer',
            height: 13,
            width: 13,
          ),
          onTap: () async {
            final textMessage = await TencentImSDKPlugin.v2TIMManager
                .getMessageManager()
                .createTextMessage(text: TDesk_t("人工服务"));
            if (textMessage.data?.messageInfo != null) {
              widget.controller
                  .sendMessage(messageInfo: textMessage.data!.messageInfo!);
            }
          },
        ),
      );
    }
    _quickMessages.addAll(config.additionalQuickMessages ?? []);
    setState(() {
      _quickMessages = _quickMessages;
    });
  }

  Future<V2TimConversation> _loadConversation() async {
    final conversationID = "c2c_${widget.customerServiceUserID}";
    V2TimConversation? targetConversation =
        _conversationViewModel.getConversation(conversationID) ??
            await _conversationService.getConversation(
                conversationID: conversationID);
    if (targetConversation == null) {
      V2TimUserFullInfo? userProfile;
      final userProfileRes =
          await TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: [
        widget.customerServiceUserID,
      ]);
      if (userProfileRes.data != null && userProfileRes.data!.isNotEmpty) {
        userProfile = userProfileRes.data!.first;
      }
      targetConversation = V2TimConversation(
        conversationID: conversationID,
        userID: widget.customerServiceUserID,
        faceUrl: TencentDeskUtils.checkString(userProfile?.faceUrl),
        showName: TencentDeskUtils.checkString(userProfile?.nickName) ??
            TencentDeskUtils.checkString(userProfile?.userID) ??
            TencentDeskUtils.checkString(widget.customerServiceUserID) ??
            TDesk_t("智能客服"),
        type: 1,
      );
    }
    setState(() {
      _customerServiceConversation = targetConversation;
    });
    _sendStartMessage(0);
    return targetConversation;
  }

  Widget? _quickMessagesWidget() {
    return widget.builder.quickMessagesBuilder != null
        ? widget.builder.quickMessagesBuilder!(quickMessages: _quickMessages)
        : _quickMessages.isNotEmpty
            ? SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _quickMessages.map((quickMessage) {
                    return Container(
                      margin: const EdgeInsets.only(
                        left: 16,
                        bottom: 4,
                        top: 12,
                      ),
                      child: TencentCloudCustomerMessageQuickMessage(
                        quickMessage: quickMessage,
                      ),
                    );
                  }).toList(),
                ),
              )
            : null;
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final targetConversation = _customerServiceConversation;
    return targetConversation != null
        ? TencentCloudCustomerMessage(
            backgroundImage: widget.config.backgroundImageAsset,
            conversation: targetConversation,
            customAppBar: widget.builder.headerBuilder != null
                ? widget.builder.headerBuilder!(
                    conversation: targetConversation,
                    targetTypingIndicator: _customerServiceTyping,
                  )
                : TencentCloudCustomerMessageHeader(
                    conversation: targetConversation,
                    headerLabel: _customerServiceTyping,
                  ),
            inputTopBuilder: _quickMessagesWidget(),
            tongueItemBuilder: (VoidCallback onClick,
                    MessageListTongueType valueType, int unreadCount) =>
                widget.builder.tongueItemBuilder != null
                    ? widget.builder.tongueItemBuilder!(
                        onClick,
                        valueType,
                        unreadCount,
                      )
                    : TencentCloudCustomerTongueItem(
                        onClick: onClick,
                        valueType: valueType,
                        previousCount: 0,
                        unreadCount: unreadCount,
                        atNum: "",
                      ),
            conversationShowName:
                _customerServiceTyping ?? targetConversation.showName,
            lifeCycle: ChatLifeCycle(
              newMessageWillMount: (V2TimMessage message) async {
                if (TencentCloudChatCustomerServicePlugin
                    .isCustomerServiceMessage(message)) {
                  if (TencentCloudChatCustomerServicePlugin
                      .isTypingCustomerServiceMessage(message)) {
                    setState(() {
                      _customerServiceTyping = TDesk_t("对方正在输入中...");
                    });
                  }
                } else {
                  setState(() {
                    _customerServiceTyping = null;
                  });
                }
                return message;
              },
              messageShouldMount: (V2TimMessage message) {
                if (TencentCloudChatCustomerServicePlugin
                    .isCustomerServiceMessage(message)) {
                  return !TencentCloudChatCustomerServicePlugin
                          .isCustomerServiceMessageInvisible(message) &&
                      !(message.isSelf ?? true);
                }
                return widget.eventHandler.shouldMountMessage(message);
              },
              messageDidSend: widget.eventHandler.didSendMessage,
              shouldDeleteMessage: widget.eventHandler.shouldDeleteMessage,
              shouldClearHistoricalMessageList: widget.eventHandler.shouldClearMessageList,
              messageListShouldMount: widget.eventHandler.shouldMountMessageList,
            ),
            morePanelConfig: MorePanelConfig(
              showVideoCall: false,
              showVoiceCall: false,
            ),
            toolTipsConfig: ToolTipsConfig(
              showForwardMessage: false,
              showMultipleChoiceMessage: false,
              showTranslation: false,
            ),
            config: TIMUIKitChatConfig(
              onTapLink: widget.eventHandler.onTapLink,
              isUseMessageReaction: false,
              isShowAvatar: false,
              textHeight: kTextHeightNone,
              isShowReadingStatus: widget.config.useMessageReadReceipt ?? false,
              stickerPanelConfig: StickerPanelConfig(
                useTencentCloudChatStickerPackage: true,
                useQQStickerPackage: false,
                useTencentCloudChatStickerPackageOldKeys: false,
                unicodeEmojiList: [],
                customStickerPackages: [],
              ),
            ),
            messageItemBuilder: DeskMessageItemBuilder(
              messageRowBuilder: (
                V2TimMessage message,
                Widget messageWidget,
                Function onScrollToIndex,
                bool isNeedShowJumpStatus,
                VoidCallback clearJumpStatus,
                Function onScrollToIndexBegin,
              ) {
                if (TencentCloudChatCustomerServicePlugin
                    .isCustomerServiceMessage(message)) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: messageWidget,
                        )
                      ],
                    ),
                  );
                }
                return widget.builder.regularMessageItemBuilder
                            ?.messageRowBuilder !=
                        null
                    ? widget
                        .builder.regularMessageItemBuilder!.messageRowBuilder!(
                        message,
                        messageWidget,
                        onScrollToIndex,
                        isNeedShowJumpStatus,
                        clearJumpStatus,
                        onScrollToIndexBegin,
                      )
                    : null;
              },
              customMessageItemBuilder: (message, isShowJump, clearJump) {
                if (TencentCloudChatCustomerServicePlugin
                    .isCustomerServiceMessage(message)) {
                  Widget? botMessage =
                      widget.builder.deskChatBotMessagesBuilder != null
                          ? widget.builder.deskChatBotMessagesBuilder!(
                              message: message,
                              isShowJump: isShowJump,
                              clearJump: clearJump,
                            )
                          : null;
                  botMessage ??= MessageCustomerService(
                    message: message,
                    textPadding: const EdgeInsets.all(16),
                    messageBackgroundColor: Colors.white,
                    theme: theme,
                    isShowJumpState: isShowJump,
                    onTapLink: widget.eventHandler.onTapLink,
                    sendMessage: widget.controller.sendMessage,
                  );
                  return Column(
                    crossAxisAlignment: message.isSelf ?? true
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      botMessage,
                      MessageBubbleButton(
                        message: message,
                        showAINote:
                            TencentCloudChatCustomerServicePlugin.canShowAINote(
                                    message) &&
                                (widget.config.enableAINote != null
                                    ? widget.config.enableAINote!
                                    : true),
                      )
                    ],
                  );
                }
                return widget.builder.regularMessageItemBuilder
                            ?.customMessageItemBuilder !=
                        null
                    ? widget.builder.regularMessageItemBuilder!
                        .customMessageItemBuilder!(
                        message,
                        isShowJump,
                        clearJump,
                      )
                    : null;
              },
              textMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.textMessageItemBuilder,
              textReplyMessageItemBuilder: widget.builder
                  .regularMessageItemBuilder?.textReplyMessageItemBuilder,
              imageMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.imageMessageItemBuilder,
              soundMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.soundMessageItemBuilder,
              videoMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.videoMessageItemBuilder,
              fileMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.fileMessageItemBuilder,
              locationMessageItemBuilder: widget.builder
                  .regularMessageItemBuilder?.locationMessageItemBuilder,
              faceMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.faceMessageItemBuilder,
              groupTipsMessageItemBuilder: widget.builder
                  .regularMessageItemBuilder?.groupTipsMessageItemBuilder,
              mergerMessageItemBuilder: widget
                  .builder.regularMessageItemBuilder?.mergerMessageItemBuilder,
              messageNickNameBuilder: widget
                  .builder.regularMessageItemBuilder?.messageNickNameBuilder,
            ),
            controller: widget.controller,
            userAvatarBuilder: widget.builder.userAvatarBuilder,
          )
        : Column(
            children: [
              Expanded(
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: theme.weakTextColor ?? Colors.grey,
                    size: 28,
                  ),
                ),
              )
            ],
          );
  }
}
