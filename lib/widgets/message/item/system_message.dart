import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../enum/message_action.dart';
import '../../../generated/l10n.dart';
import '../../../utils/extension/extension.dart';
import '../message.dart';

class SystemMessage extends HookWidget {
  const SystemMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actionName =
        useMessageConverter(converter: (state) => state.actionName);
    final participantUserId =
        useMessageConverter(converter: (state) => state.participantUserId);
    final senderId = useMessageConverter(converter: (state) => state.userId);
    final participantFullName =
        useMessageConverter(converter: (state) => state.participantFullName);
    final userFullName =
        useMessageConverter(converter: (state) => state.userFullName);
    final groupName =
        useMessageConverter(converter: (state) => state.groupName);
    final content = useMessageConverter(converter: (state) => state.content);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 8,
        ),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.dynamicColor(
                const Color.fromRGBO(202, 234, 201, 1),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10,
              ),
              child: Text(
                generateSystemText(
                  actionName: actionName,
                  participantUserId: participantUserId,
                  senderId: senderId,
                  currentUserId: context.accountServer.userId,
                  participantFullName: participantFullName,
                  senderFullName: userFullName,
                  groupName: groupName,
                  expireIn: int.tryParse(content ?? '0'),
                ),
                style: TextStyle(
                  fontSize: MessageItemWidget.secondaryFontSize,
                  color: context.dynamicColor(
                    const Color.fromRGBO(0, 0, 0, 1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String generateSystemText({
  required String? actionName,
  required String? participantUserId,
  required String? senderId,
  required String currentUserId,
  required String? participantFullName,
  required String? senderFullName,
  required String? groupName,
  required int? expireIn,
}) {
  final participantIsCurrentUser = participantUserId == currentUserId;
  final senderIsCurrentUser = senderId == currentUserId;

  String text;
  switch (actionName) {
    case MessageAction.join:
      text = Localization.current.chatGroupJoin(
        participantIsCurrentUser
            ? Localization.current.youStart
            : participantFullName ?? '',
      );
      break;
    case MessageAction.exit:
      text = Localization.current.chatGroupExit(
        participantIsCurrentUser
            ? Localization.current.youStart
            : participantFullName ?? '',
      );
      break;
    case MessageAction.add:
      text = Localization.current.chatGroupAdd(
        senderIsCurrentUser ? Localization.current.youStart : senderFullName!,
        participantIsCurrentUser
            ? Localization.current.you
            : participantFullName ?? '',
      );
      break;
    case MessageAction.remove:
      text = Localization.current.chatGroupRemove(
        senderIsCurrentUser ? Localization.current.youStart : senderFullName!,
        participantIsCurrentUser
            ? Localization.current.you
            : participantFullName ?? '',
      );
      break;
    case MessageAction.create:
      text = Localization.current.chatGroupCreate(
        senderIsCurrentUser ? Localization.current.youStart : senderFullName!,
        groupName!,
      );
      break;
    case MessageAction.role:
      text = Localization.current.chatGroupRole;
      break;
    case MessageAction.expire:
      final senderName =
          senderIsCurrentUser ? Localization.current.youStart : senderFullName!;
      if (expireIn == null) {
        text = Localization.current.chatExpiredSetWithoutDuration(senderName);
      } else if (expireIn <= 0) {
        text = Localization.current.chatExpiredDisabled(senderName);
      } else {
        text = Localization.current.chatExpiredSet(
          senderName,
          Duration(seconds: expireIn).formatAsConversationExpireIn(),
        );
      }
      break;
    case MessageAction.update:
    default:
      text = Localization.current.chatNotSupport;
      break;
  }
  return text;
}
