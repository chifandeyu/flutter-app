import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/extension/extension.dart';
import '../../../utils/uri_utils.dart';
import '../message.dart';
import '../message_bubble.dart';
import '../message_datetime_and_status.dart';
import '../message_layout.dart';

class UnknownMessage extends StatelessWidget {
  const UnknownMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = RichText(
      text: TextSpan(
        text: context.l10n.conversationNotSupport,
        style: TextStyle(
          fontSize: MessageItemWidget.primaryFontSize,
          color: context.theme.text,
        ),
        children: [
          TextSpan(
            mouseCursor: SystemMouseCursors.click,
            text: context.l10n.learnMore,
            style: TextStyle(
              fontSize: MessageItemWidget.primaryFontSize,
              color: context.theme.accent,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => openUri(context, context.l10n.chatNotSupportUrl),
          ),
        ],
      ),
    );
    return MessageBubble(
      child: MessageLayout(
        spacing: 6,
        content: content,
        dateAndStatus: const MessageDatetimeAndStatus(),
      ),
    );
  }
}
