import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/bloc_converter.dart';
import 'package:flutter_app/constants/assets.dart';
import 'package:flutter_app/ui/home/bloc/conversation_cubit.dart';
import 'package:flutter_app/ui/home/bloc/conversation_list_cubit.dart';
import 'package:flutter_app/ui/home/bloc/slide_category_cubit.dart';
import 'package:flutter_app/ui/home/route/responsive_navigator_cubit.dart';
import 'package:flutter_app/utils/datetime_format_utils.dart';
import 'package:flutter_app/widgets/avatar_view.dart';
import 'package:flutter_app/widgets/brightness_observer.dart';
import 'package:flutter_app/widgets/context_menu.dart';
import 'package:flutter_app/widgets/interacter_decorated_box.dart';
import 'package:flutter_app/widgets/search_bar.dart';
import 'package:flutter_app/widgets/unread_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_app/generated/l10n.dart';

class ConversationPage extends StatelessWidget {
  const ConversationPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BrightnessData.dynamicColor(
        context,
        const Color.fromRGBO(255, 255, 255, 1),
        darkColor: const Color.fromRGBO(44, 49, 54, 1),
      ),
      child: Column(
        children: [
          const SearchBar(),
          Expanded(
            child:
                BlocConverter<ConversationListCubit, List<Conversation>, int>(
              converter: (state) => state?.length ?? 0,
              builder: (context, itemCount) {
                if (itemCount == 0) return _Empty();
                return _List(itemCount: itemCount);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dynamicColor = BrightnessData.dynamicColor(
      context,
      const Color.fromRGBO(229, 233, 240, 1),
    );
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SvgPicture.asset(
          Assets.assetsImagesConversationEmptySvg,
          height: 78,
          width: 58,
          color: dynamicColor,
        ),
        const SizedBox(height: 24),
        Text(
          Localization.of(context).noData,
          style: TextStyle(
            color: dynamicColor,
            fontSize: 14,
          ),
        ),
      ]),
    );
  }
}

class _List extends StatelessWidget {
  const _List({
    Key key,
    this.itemCount,
  }) : super(key: key);

  final int itemCount;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SlideCategoryCubit, SlideCategoryState>(
        builder: (context, slideCategoryState) => ListView.builder(
          key: PageStorageKey(slideCategoryState),
          itemCount: itemCount,
          itemBuilder: (BuildContext context, int index) => BlocConverter<
              ConversationListCubit, List<Conversation>, Conversation>(
            converter: (state) => state[index],
            builder: (context, message) =>
                BlocConverter<ConversationCubit, Conversation, bool>(
              converter: (state) => message == state,
              builder: (context, selected) => _Item(
                selected: selected,
                avatars: message.avatars,
                name: message.name,
                dateTime: message.dateTime,
                messageStatus: message.messageStatus,
                message: message.message,
                count: message.count,
                unread: message.unread,
                onTap: () {
                  BlocProvider.of<ConversationCubit>(context).emit(message);
                  ResponsiveNavigatorCubit.of(context)
                      .pushPage(ResponsiveNavigatorCubit.chatPage);
                },
                onRightClick: (pointerUpEvent) => ContextMenuRoute.show(
                  context,
                  pointerPosition: pointerUpEvent.position,
                  menus: [
                    ContextMenu(
                      title: Localization.of(context).pin,
                      onTap: () {},
                    ),
                    ContextMenu(
                      title: Localization.of(context).unMute,
                      onTap: () {},
                    ),
                    ContextMenu(
                      title: Localization.of(context).deleteChat,
                      isDestructiveAction: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _Item extends StatelessWidget {
  const _Item({
    Key key,
    this.selected = false,
    @required this.avatars,
    @required this.name,
    @required this.dateTime,
    @required this.messageStatus,
    @required this.message,
    this.count = 0,
    this.unread = false,
    this.onTap,
    this.onRightClick,
  }) : super(key: key);

  final bool selected;
  final List<String> avatars;
  final String name;
  final DateTime dateTime;
  final String messageStatus;
  final String message;
  final int count;
  final bool unread;
  final VoidCallback onTap;
  final ValueChanged<PointerUpEvent> onRightClick;

  @override
  Widget build(BuildContext context) {
    final messageColor = BrightnessData.dynamicColor(
      context,
      const Color.fromRGBO(184, 189, 199, 1),
      darkColor: const Color.fromRGBO(255, 255, 255, 0.4),
    );
    return InteractableDecoratedBox(
      onTap: onTap,
      onRightClick: onRightClick,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DecoratedBox(
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: BrightnessData.dynamicColor(
                    context,
                    const Color.fromRGBO(246, 247, 250, 1),
                    darkColor: const Color.fromRGBO(255, 255, 255, 0.06),
                  ),
                )
              : const BoxDecoration(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: AvatarsWidget(
                    size: 50,
                    avatars: avatars,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: BrightnessData.dynamicColor(
                                    context,
                                    const Color.fromRGBO(51, 51, 51, 1),
                                    darkColor: const Color.fromRGBO(
                                        255, 255, 255, 0.9),
                                  ),
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              convertStringTime(dateTime),
                              style: TextStyle(
                                color: messageColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              Expanded(
                                child: _MessagePreview(
                                  messageColor: messageColor,
                                  messageStatus: messageStatus,
                                  message: message,
                                ),
                              ),
                              UnreadText(
                                count: count,
                                backgroundColor: unread
                                    ? BrightnessData.dynamicColor(
                                        context,
                                        const Color.fromRGBO(61, 117, 227, 1),
                                        darkColor: const Color.fromRGBO(
                                            65, 145, 255, 1),
                                      )
                                    : BrightnessData.dynamicColor(
                                        context,
                                        const Color.fromRGBO(184, 189, 199, 1),
                                        darkColor: const Color.fromRGBO(
                                            255, 255, 255, 0.4),
                                      ),
                                textColor: unread
                                    ? BrightnessData.dynamicColor(
                                        context,
                                        const Color.fromRGBO(255, 255, 255, 1),
                                        darkColor: const Color.fromRGBO(
                                            255, 255, 255, 1),
                                      )
                                    : BrightnessData.dynamicColor(
                                        context,
                                        const Color.fromRGBO(255, 255, 255, 1),
                                        darkColor:
                                            const Color.fromRGBO(44, 49, 54, 1),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MessagePreview extends StatelessWidget {
  const _MessagePreview({
    Key key,
    @required this.messageColor,
    this.messageStatus,
    this.message,
  }) : super(key: key);

  final Color messageColor;
  final String messageStatus;
  final String message;

  @override
  Widget build(BuildContext context) => Text(
        message,
        style: TextStyle(
          color: messageColor,
          fontSize: 14,
        ),
        overflow: TextOverflow.ellipsis,
      );
}
