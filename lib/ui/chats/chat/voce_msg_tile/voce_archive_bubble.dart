import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocechat_client/api/models/msg/msg_archive/archive.dart';
import 'package:vocechat_client/api/models/msg/msg_archive/archive_msg.dart';
import 'package:vocechat_client/api/models/msg/msg_archive/archive_user.dart';
import 'package:vocechat_client/models/ui_models/msg_tile_data.dart';
import 'package:vocechat_client/services/file_handler.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/app_icons_icons.dart';
import 'package:vocechat_client/ui/chats/chat/message_tile/archive_page.dart';
import 'package:vocechat_client/ui/chats/chat/voce_msg_tile/empty_data_placeholder.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocechat_client/ui/chats/chat/voce_msg_tile/voce_archive_content_bubble.dart';

class VoceArchiveBubble extends StatefulWidget {
  final MsgTileData? tileData;

  final bool isFullPage;
  final int lengthLimit;

  late Archive? archive;
  late String archiveId;

  VoceArchiveBubble.tileData(
      {Key? key,
      required MsgTileData this.tileData,
      this.isFullPage = false,
      this.lengthLimit = 3})
      : super(key: key) {
    archive = tileData!.archive;
    archiveId = tileData!.chatMsgMNotifier.value.msgNormal?.content ??
        tileData!.chatMsgMNotifier.value.msgReply?.content ??
        "";
  }

  VoceArchiveBubble.data(
      {Key? key,
      required this.archive,
      required this.archiveId,
      this.isFullPage = false,
      this.lengthLimit = 3})
      : tileData = null,
        super(key: key);

  @override
  State<VoceArchiveBubble> createState() => _VoceArchiveBubbleState();
}

class _VoceArchiveBubbleState extends State<VoceArchiveBubble> {
  List<ArchiveUser> users = [];
  List<ArchiveMsg> msgs = [];

  bool afterServerPrepare = false;

  @override
  void initState() {
    super.initState();

    users = widget.archive?.users ?? [];
    msgs = widget.archive?.messages ?? [];

    if (widget.tileData != null && widget.tileData!.needServerPrepare) {
      widget.tileData!.serverPrepare().then((_) {
        setState(() {
          widget.archive = widget.tileData!.archive;
          widget.archiveId =
              widget.tileData!.chatMsgMNotifier.value.msgNormal!.content;

          users = widget.archive?.users ?? [];
          msgs = widget.archive?.messages ?? [];

          afterServerPrepare = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tileData != null && widget.tileData!.needServerPrepare) {
      if (afterServerPrepare) {
        // no server data
        return const EmptyDataPlaceholder();
      } else {
        return CupertinoActivityIndicator();
      }
    } else {
      return _buildArchiveMsgList();
    }
  }

  Widget _buildArchiveMsgList() {
    final listLength = calListLength();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.grey100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.forward, size: 12, color: AppColors.grey400),
              const SizedBox(width: 4),
              Text(AppLocalizations.of(context)!.forwarded,
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.grey400))
            ],
          ),
          const SizedBox(height: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(listLength, (index) {
              if (!widget.isFullPage && index == widget.lengthLimit) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: !enableDetailPage()
                          ? null
                          : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ArchivePage(
                                  archive: widget.archive,
                                  filePath: widget.archiveId,
                                  getFile: getFile))),
                      child: Text(
                        " ${AppLocalizations.of(context)!.archiveBubbleAnd} ${msgs.length - widget.lengthLimit} ${AppLocalizations.of(context)!.archiveBubbleMore}",
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }

              final msg = msgs[index];
              final user = users[msg.fromUser];

              return VoceArchiveContentBubble(
                  archiveMsg: msg,
                  archiveId: widget.archiveId,
                  archiveUser: user,
                  getFile: getFile);
            }),
          )
        ],
      ),
    );
  }

  int calListLength() {
    if (widget.isFullPage) {
      return widget.archive!.messages.length;
    } else {
      return msgs.length <= widget.lengthLimit
          ? msgs.length
          : widget.lengthLimit + 1;
    }
  }

  bool enableDetailPage() {
    return !widget.isFullPage && msgs.length > widget.lengthLimit;
  }

  Future<File?> getFile(String filePath, int msgId, String fileName) {
    return FileHandler.singleton.getArchiveFile(filePath, msgId, fileName);
  }
}