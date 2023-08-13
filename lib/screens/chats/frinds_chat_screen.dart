import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/shared/provider/app_provider.dart';
import 'package:chat_app/shared/styles/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../helper/helper_functions.dart';
import '../../widgets/friend_messages_tile.dart';

class FriendsChatScreen extends StatefulWidget {
  const FriendsChatScreen({
    Key? key,
    required this.friendId,
    required this.friendName,
    required this.bio,
  }) : super(key: key);

  final String friendName;
  final String friendId;
  final String bio;

  @override
  State<FriendsChatScreen> createState() => _FriendsChatScreenState();
}

class _FriendsChatScreenState extends State<FriendsChatScreen> {
  TextEditingController messageController = TextEditingController();
  Stream<QuerySnapshot>? chats;
  bool emojiShowing = false;
  String userName = "";

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  _onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  @override
  void initState() {
    getChatData();
    getSenderName();
    super.initState();
  }

  getSenderName()async {
    await HelperFunctions.getUserNameFromSp().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  getChatData() {
    DatabaseServices().getFriendsChats(widget.friendId).then((value) {
      setState(() {
        chats = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyAppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.friendName,
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          chatMessages(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
              height: 60.h,
              color: Colors.grey[600],
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextField(
                          controller: messageController,
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: provider.themeMode == ThemeMode.light
                                  ? Colors.black87
                                  : AppColors.lightColor),
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            filled: true,
                            fillColor: provider.themeMode == ThemeMode.light
                                ? Colors.white
                                : AppColors.darkColor,
                            contentPadding: const EdgeInsets.only(
                                left: 16.0, bottom: 8.0, top: 8.0, right: 16.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(50.r),
                            ),
                          )),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                        onPressed: () {
                          sendMessageToFriend();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        )),
                  )
                ],
              )),
          Offstage(
            offstage: !emojiShowing,
            child: SizedBox(
                height: 220.h,
                child: EmojiPicker(
                  textEditingController: messageController,
                  onBackspacePressed: _onBackspacePressed,
                  config: Config(
                    columns: 7,
                    emojiSizeMax: 30 *
                        (foundation.defaultTargetPlatform == TargetPlatform.iOS
                            ? 1.30
                            : 1.0),
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    initCategory: Category.RECENT,
                    bgColor: provider.themeMode == ThemeMode.light
                        ? const Color(0xFFF2F2F2)
                        : AppColors.darkColor,
                    indicatorColor: AppColors.primaryColor,
                    iconColor: Colors.grey,
                    iconColorSelected: AppColors.primaryColor,
                    backspaceColor: AppColors.primaryColor,
                    skinToneDialogBgColor: Colors.white,
                    skinToneIndicatorColor: Colors.grey,
                    enableSkinTones: true,
                    recentTabBehavior: RecentTabBehavior.RECENT,
                    recentsLimit: 28,
                    replaceEmojiOnLimitExceed: false,
                    noRecents: Text(
                      'No Recents',
                      style: TextStyle(fontSize: 16.sp, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    loadingIndicator: const SizedBox.shrink(),
                    tabIndicatorAnimDuration: kTabScrollDuration,
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL,
                    checkPlatformCompatibility: true,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  chatMessages() {
    return Expanded(
      child: StreamBuilder(
        stream: chats,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return FriendMessagesTile(
                      message: snapshot.data.docs[index]['message'],
                      sender: snapshot.data.docs[index]['sender'],
                      sentByMe: widget.friendName ==
                          snapshot.data.docs[index]['sender'],
                      timeOfMessage: snapshot.data.docs[index]['time'],
                      friendId: widget.friendId,
                      messageId: snapshot.data.docs[index].id, userId: FirebaseAuth.instance.currentUser!.uid,
                    );
                  },
                )
              : Container();
        },
      ),
    );
  }

  void sendMessageToFriend() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageData = {
        "message": messageController.text,
        "sender": userName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
          .sendMessageToFriend(FirebaseAuth.instance.currentUser!.uid,
              widget.friendId, chatMessageData);
      setState(() {
        messageController.clear();
      });
    }
  }
}
