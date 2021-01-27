import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/account/account_server.dart';
import 'package:flutter_app/bloc/bloc_converter.dart';
import 'package:flutter_app/db/mixin_database.dart';
import 'package:flutter_app/utils/color_utils.dart';
import 'package:flutter_app/widgets/avatar_view/bloc/cubit/avatar_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:provider/provider.dart';

class ConversationAvatarWidget extends StatelessWidget {
  const ConversationAvatarWidget({
    Key key,
    @required this.conversation,
    @required this.size,
  }) : super(key: key);

  final ConversationItem conversation;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.fromSize(
        size: Size.square(size),
        child: ClipOval(
          child: Builder(
            builder: (context) {
              if (conversation.groupIconUrl != null)
                return _Image(
                  conversation.groupIconUrl,
                  size,
                );
              return BlocProvider(
                key: Key(conversation.conversationId),
                create: (context) => AvatarCubit(
                  Provider.of<AccountServer>(context, listen: false)
                      .database
                      .participantsDao,
                  conversation,
                ),
                child: Builder(
                  builder: (context) => BlocConverter<AvatarCubit,
                      List<UserItem>, List<UserItem>>(
                    // todo: relationship enum
                    converter: (state) => conversation.category ==
                            ConversationCategory.contact
                        ? state
                            .where((element) => element.relationship != 'ME')
                            .toList()
                        : state,
                    builder: (context, state) =>
                        _AvatarPuzzlesWidget(state, size),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _AvatarPuzzlesWidget extends StatelessWidget {
  const _AvatarPuzzlesWidget(this.users, this.size, {Key key})
      : super(key: key);

  final List<UserItem> users;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (users?.isEmpty ?? true)
      return SizedBox.fromSize(size: Size.square(size));
    switch (users.length) {
      case 1:
        return AvatarWidget(user: users.single, size: size);
      case 2:
        return Row(
          children: users.map(_buildAvatarImage).toList(),
        );
      case 3:
        return Row(
          children: [
            Expanded(child: AvatarWidget(user: users[0], size: size)),
            Expanded(
              child: Column(
                children: users.sublist(1).map(_buildAvatarImage).toList(),
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            users.sublist(0, 2),
            users.sublist(2),
          ]
              .map((e) => Expanded(
                    child: Column(
                      children: e.map(_buildAvatarImage).toList(),
                    ),
                  ))
              .toList(),
        );
    }
  }

  Widget _buildAvatarImage(UserItem user) => Expanded(
        child: AvatarWidget(user: user, size: size),
      );
}

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    Key key,
    @required this.user,
    @required this.size,
  }) : super(key: key);

  final UserItem user;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (user.avatarUrl?.isNotEmpty == true) return _Image(user.avatarUrl, size);
    return SizedBox.fromSize(
      size: Size.square(size),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: getAvatarColorById(user.userId),
        ),
        child: Center(
          child: Text(
            user.fullName[0],
            style: TextStyle(
              color: getNameColorById(user.userId),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image(
    this.src,
    this.size, {
    Key key,
  }) : super(key: key);

  final String src;
  final double size;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: src,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
      );
}
