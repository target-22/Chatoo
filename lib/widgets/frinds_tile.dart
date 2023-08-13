import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/screens/chats/frinds_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/styles/app_colors.dart';
import 'widgets.dart';

class FriendTile extends StatefulWidget {
  const FriendTile(
      {Key? key,
      required this.friendId,
      required this.friendName,
      required this.bio})
      : super(key: key);

  final String friendName;
  final String friendId;
  final String bio;

  @override
  State<FriendTile> createState() => _FriendTileState();
}

class _FriendTileState extends State<FriendTile> {
  String userName = "";

  @override
  void initState() {
    super.initState();
    getSenderName();
  }

getSenderName()async {
  await HelperFunctions.getUserNameFromSp().then((value) {
    setState(() {
      userName = value!;
    });
  });
}
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            FriendsChatScreen(
              friendName: widget.friendName,
              friendId: widget.friendId,
              bio: widget.bio
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            child: Text(widget.friendName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500, color: Colors.white)),
          ),
          title: Text(
            widget.friendName,
            style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.bio,
            style: GoogleFonts.ubuntu(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
