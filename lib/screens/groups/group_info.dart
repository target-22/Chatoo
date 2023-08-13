import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/styles/app_colors.dart';
import 'groups_screen.dart';

class GroupInfo extends StatefulWidget {
  const GroupInfo(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.adminName});

  final String adminName;
  final String groupId;
  final String groupName;

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  Stream? members;

  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() {
    DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupMembers(widget.groupId)
        .then((value) {
      setState(() {
        members = value;
      });
    });
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Group Info",
          style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Exit"),
                      content:
                          const Text("Are you sure you want Exit the group ?"),
                      actions: [
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            )),
                        IconButton(
                            onPressed: () {
                              DatabaseServices().deleteUser(widget.groupId);
                              DatabaseServices(
                                      uid: FirebaseAuth
                                          .instance.currentUser!.uid)
                                  .toggleGroupJoinExit(
                                      widget.groupId,
                                      getName(widget.adminName),
                                      widget.groupName);
                              nextScreenReplace(context, const GroupsScreen());
                            },
                            icon: const Icon(
                              Icons.done,
                              color: Colors.green,
                            )),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      widget.adminName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.04,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Group: ${widget.groupName}",
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w500, fontSize: 15.sp),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        "Admin: ${getName(widget.adminName)}",
                        style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w500, fontSize: 15.sp),
                      ),
                    ],
                  )
                ],
              ),
            ),
            memberList(),
          ],
        ),
      ),
    );
  }

  memberList() {
    return StreamBuilder(
        stream: members,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['members'] != null) {
              if (snapshot.data['members'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['members'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25.r,
                              backgroundColor: AppColors.primaryColor,
                              child: Text(
                                getName(snapshot.data['members'][index])
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                            title:
                                Text(getName(snapshot.data['members'][index])),
                            subtitle: Text(
                              "ID: ${getId(snapshot.data['members'][index])}",
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ));
                    });
              } else {
                return const Center(child: Text("NO MEMBERS"));
              }
            } else {
              return const Center(child: Text("NO MEMBERS"));
            }
          } else {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }
        });
  }
}
