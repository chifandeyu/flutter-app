import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../bloc/keyword_cubit.dart';
import '../constants/resources.dart';
import '../utils/extension/extension.dart';
import '../utils/hook.dart';
import 'action_button.dart';
import 'actions/actions.dart';
import 'dialog.dart';
import 'menu.dart';
import 'search_text_field.dart';
import 'toast.dart';
import 'user/user_dialog.dart';
import 'window/move_window.dart';

class SearchBar extends HookWidget {
  const SearchBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => MoveWindow(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: MoveWindowBarrier(
                  child: SearchTextField(
                    focusNode: context.read<FocusNode>(),
                    controller: context.read<TextEditingController>(),
                    onChanged: (keyword) =>
                        context.read<KeywordCubit>().emit(keyword),
                    hintText: context.l10n.search,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ContextMenuPortalEntry(
                buildMenus: () => [
                  ContextMenu(
                    title: context.l10n.searchContact,
                    onTap: () => showMixinDialog<String>(
                      context: context,
                      child: const _SearchUserDialog(),
                    ),
                  ),
                  ContextMenu(
                    title: context.l10n.createConversation,
                    onTap: () {
                      Actions.maybeInvoke(
                        context,
                        const CreateConversationIntent(),
                      );
                    },
                  ),
                  ContextMenu(
                    title: context.l10n.createGroup,
                    onTap: () async {
                      Actions.maybeInvoke(
                        context,
                        const CreateGroupConversationIntent(),
                      );
                    },
                  ),
                  ContextMenu(
                    title: context.l10n.createCircle,
                    onTap: () async {
                      Actions.maybeInvoke(
                        context,
                        const CreateCircleIntent(),
                      );
                    },
                  ),
                ],
                child: Builder(
                  builder: (context) => MoveWindowBarrier(
                    child: ActionButton(
                      name: Resources.assetsImagesIcAddSvg,
                      onTapUp: (event) =>
                          context.sendMenuPosition(event.globalPosition),
                      color: context.theme.icon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      );
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _SearchUserDialog extends HookWidget {
  const _SearchUserDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentIdentityNumber = context.multiAuthState.currentIdentityNumber;

    final textEditingController = useTextEditingController();
    final textEditingValueStream =
        useValueNotifierConvertSteam(textEditingController);
    final searchable = useMemoizedStream(() => textEditingValueStream.map(
                (event) =>
                    event.text.trim().length > 3 && event.composing.composed))
            .data ??
        false;

    final loading = useState(false);
    final resultUserId = useState<String?>(null);

    Future<void> search() async {
      if (!searchable) return;

      loading.value = true;
      try {
        final mixinResponse = await context.accountServer.client.userApi
            .search(textEditingController.text);
        await context.database.userDao.insertSdkUser(mixinResponse.data);
        resultUserId.value = mixinResponse.data.userId;
      } catch (e) {
        unawaited(
            showToastFailed(context, ToastError(context.l10n.userNotFound)));
      }

      loading.value = false;
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Builder(
        builder: (BuildContext context) {
          if (resultUserId.value?.isNotEmpty ?? false) {
            return UserDialog(
              userId: resultUserId.value!,
            );
          }

          return Stack(
            children: [
              Visibility(
                visible: !loading.value,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: AlertDialogLayout(
                  title: Text(context.l10n.addContact),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FocusableActionDetector(
                        autofocus: true,
                        shortcuts: {
                          if (searchable)
                            const SingleActivator(LogicalKeyboardKey.enter):
                                const _SearchIntent(),
                        },
                        actions: {
                          _SearchIntent: CallbackAction<Intent>(
                            onInvoke: (Intent intent) => search(),
                          ),
                        },
                        child: DialogTextField(
                          textEditingController: textEditingController,
                          hintText: context.l10n.addPeopleSearchHint,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
                          ],
                        ),
                      ),
                      if (currentIdentityNumber?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            context.l10n.myMixinId(currentIdentityNumber!),
                            style: TextStyle(
                              color: context.theme.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    MixinButton(
                        backgroundTransparent: true,
                        onTap: () => Navigator.pop(context),
                        child: Text(context.l10n.cancel)),
                    MixinButton(
                      disable: !searchable,
                      onTap: search,
                      child: Text(context.l10n.search),
                    ),
                  ],
                ),
              ),
              if (loading.value)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Align(
                    child:
                        CircularProgressIndicator(color: context.theme.accent),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
