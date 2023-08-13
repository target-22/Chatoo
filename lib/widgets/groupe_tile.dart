import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/groups/groups_chat_screen.dart';
import '../shared/styles/app_colors.dart';
import 'widgets.dart';

class GroupTile extends StatefulWidget {
  const GroupTile({
    Key? key,
    required this.groupId,
    required this.groupName,
    required this.userName,
  }) : super(key: key);

  final String userName;
  final String groupId;
  final String groupName;

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            GroupsChatScreen(
              userName: widget.userName,
              groupName: widget.groupName,
              groupId: widget.groupId,
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            child: Text(widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500, color: Colors.white)),
          ),
          title: Text(
            widget.groupName,
            style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversation as ${widget.userName}",
            style: GoogleFonts.ubuntu(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
