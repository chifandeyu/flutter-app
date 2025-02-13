import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../../constants/resources.dart';
import '../../../db/extension/conversation.dart';
import '../../../db/mixin_database.dart';
import '../../../utils/extension/extension.dart';
import '../../../utils/hook.dart';
import '../../../widgets/conversation/mute_dialog.dart';
import '../../../widgets/dialog.dart';
import '../../../widgets/menu.dart';
import '../../../widgets/toast.dart';
import '../bloc/conversation_cubit.dart';
import '../bloc/slide_category_cubit.dart';

class ConversationMenuWrapper extends StatelessWidget {
  const ConversationMenuWrapper({
    Key? key,
    this.conversation,
    this.searchConversation,
    required this.child,
    this.removeChatFromCircle = false,
  }) : super(key: key);

  final ConversationItem? conversation;
  final SearchConversationItem? searchConversation;
  final Widget child;
  final bool removeChatFromCircle;

  @override
  Widget build(BuildContext context) {
    assert(conversation != null || searchConversation != null);

    final conversationId =
        conversation?.conversationId ?? searchConversation!.conversationId;
    final ownerId = conversation?.ownerId ?? searchConversation!.ownerId;
    final pinTime = conversation?.pinTime ?? searchConversation?.pinTime;
    final isMute = conversation?.isMute ?? searchConversation!.isMute;
    final isGroupConversation = conversation?.isGroupConversation ??
        searchConversation!.isGroupConversation;

    return ContextMenuPortalEntry(
      buildMenus: () => [
        if (pinTime != null)
          ContextMenu(
            icon: Resources.assetsImagesContextMenuUnpinSvg,
            title: context.l10n.unPin,
            onTap: () => runFutureWithToast(
              context,
              context.accountServer.unpin(conversationId),
            ),
          ),
        if (pinTime == null)
          ContextMenu(
            icon: Resources.assetsImagesContextMenuPinSvg,
            title: context.l10n.pin,
            onTap: () => runFutureWithToast(
              context,
              context.accountServer.pin(conversationId),
            ),
          ),
        if (isMute)
          ContextMenu(
            icon: Resources.assetsImagesContextMenuMuteSvg,
            title: context.l10n.unMute,
            onTap: () async {
              await runFutureWithToast(
                context,
                context.accountServer.unMuteConversation(
                  conversationId: isGroupConversation ? conversationId : null,
                  userId: isGroupConversation ? null : ownerId,
                ),
              );
              return;
            },
          )
        else
          ContextMenu(
            icon: Resources.assetsImagesContextMenuUnmuteSvg,
            title: context.l10n.muted,
            onTap: () async {
              final result = await showMixinDialog<int?>(
                  context: context, child: const MuteDialog());
              if (result == null) return;
              await runFutureWithToast(
                context,
                context.accountServer.muteConversation(
                  result,
                  conversationId: isGroupConversation ? conversationId : null,
                  userId: isGroupConversation ? null : ownerId,
                ),
              );
              return;
            },
          ),
        HookBuilder(builder: (_) {
          final menus = useMemoizedFuture(
                  () => context.database.circleDao
                      .otherCircleByConversationId(conversationId)
                      .get(),
                  null,
                  keys: []).data ??
              [];
          return SubContextMenu(
              icon: Resources.assetsImagesCircleSvg,
              title: context.l10n.addToCircle,
              menus: menus
                  .map((e) => ContextMenu(
                        title: e.name,
                        onTap: () async {
                          await runFutureWithToast(
                            context,
                            () async {
                              await context.accountServer
                                  .editCircleConversation(
                                e.circleId,
                                [
                                  CircleConversationRequest(
                                    action: CircleConversationAction.add,
                                    conversationId: conversationId,
                                    userId:
                                        isGroupConversation ? null : ownerId,
                                  ),
                                ],
                              );
                            }(),
                          );
                        },
                      ))
                  .toList());
        }),
        ContextMenu(
          icon: Resources.assetsImagesContextMenuDeleteSvg,
          title: context.l10n.deleteChat,
          isDestructiveAction: true,
          onTap: () async {
            final name =
                conversation?.validName ?? searchConversation!.validName;
            final ret = await showConfirmMixinDialog(
              context,
              context.l10n.deleteChatHint(name),
              description: context.l10n.deleteChatDescription,
            );
            if (!ret) {
              return;
            }
            await context.database.conversationDao
                .deleteConversation(conversationId);
            await context.database.pinMessageDao
                .deleteByConversationId(conversationId);
            if (context.read<ConversationCubit>().state?.conversationId ==
                conversationId) {
              context.read<ConversationCubit>().unselected();
            }
          },
        ),
        if (removeChatFromCircle)
          HookBuilder(builder: (_) {
            final circleId = useBlocStateConverter<SlideCategoryCubit,
                SlideCategoryState, String?>(converter: (state) {
              if (state.type != SlideCategoryType.circle) return null;
              return state.id;
            });

            if (circleId?.isEmpty ?? true) return const SizedBox();

            return ContextMenu(
              icon: Resources.assetsImagesContextMenuDeleteSvg,
              title: context.l10n.removeChatFromCircle,
              isDestructiveAction: true,
              onTap: () async {
                await runFutureWithToast(
                  context,
                  context.accountServer.editCircleConversation(
                    circleId!,
                    [
                      CircleConversationRequest(
                        action: CircleConversationAction.remove,
                        conversationId: conversationId,
                        userId: isGroupConversation ? null : ownerId,
                      )
                    ],
                  ),
                );
              },
            );
          }),
      ],
      child: child,
    );
  }
}
