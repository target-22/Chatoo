import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../helper/helper_functions.dart';
import '../../services/database_services.dart';
import '../../shared/styles/app_colors.dart';
import '../groups/groups_chat_screen.dart';

class SearchOnGroupsScreen extends StatefulWidget {
  const SearchOnGroupsScreen({super.key});

  @override
  State<SearchOnGroupsScreen> createState() => _SearchOnGroupsScreenState();
}

class _SearchOnGroupsScreenState extends State<SearchOnGroupsScreen> {
  TextEditingController searchOnGroupsController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  @override
  void initState() {
    getCurrentUserIdAndName();
    super.initState();
  }

  String getName(String r) {
    return r.substring(r.indexOf("_") + 1);
  }

  String getId(String res) {
    return res.substring(0, res.indexOf("_"));
  }

  getCurrentUserIdAndName() async {
    await HelperFunctions.getUserNameFromSp().then((value) {
      setState(() {
        userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: Text(
          "Search",
          style: GoogleFonts.ubuntu(
              fontSize: 18.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchOnGroupsController,
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search groups....",
                        hintStyle: GoogleFonts.novaFlat(
                            color: Colors.white, fontSize: 16)),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    searchOnGroupsMethod();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryColor),
                )
              : groupList(),
        ],
      ),
    );
  }

  searchOnGroupsMethod() async {
    if (searchOnGroupsController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseServices()
          .searchGroupsByName(searchOnGroupsController.text)
          .then((snapshot) {
        setState(() {
          searchSnapshot = snapshot;
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchSnapshot!.docs.length,
            itemBuilder: (context, index) {
              return groupTitle(
                userName,
                searchSnapshot!.docs[index]["groupId"],
                searchSnapshot!.docs[index]["groupName"],
                searchSnapshot!.docs[index]["admin"],
              );
            })
        : Center(
            child: Text(
            "No results found.",
            style: Theme.of(context).textTheme.bodyMedium,
          ));
  }

  joinedOrNot(String userName, String groupId, String groupName,
      String adminName) async {
    await DatabaseServices(uid: user!.uid)
        .isUserJoined(groupName, groupId, userName)
        .then((value) {
      setState(() {
        isJoined = value;
      });
    });
  }

  Widget groupTitle(
      String userName, String groupId, String groupName, String adminName) {
    //check whether user already exists in group
    joinedOrNot(userName, groupId, groupName, adminName);
    return InkWell(
      onTap: () {
        isJoined
            ? nextScreen(
                context,
                GroupsChatScreen(
                    groupId: groupId, groupName: groupName, userName: userName))
            : null;
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primaryColor,
            child: Text(
              getName(groupName).substring(0, 1).toUpperCase(),
              style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          title: Text(
            groupName,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          subtitle: Text(
            "Admin: ${getName(adminName)}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: InkWell(
            onTap: () async {
              await DatabaseServices(uid: user!.uid)
                  .toggleGroupJoinExit(groupId, userName, groupName);
              if (isJoined) {
                setState(() {
                  isJoined = !isJoined;
                });
                showSnackBar(
                    context, Colors.green, "Successfully joined he group");
                Future.delayed(const Duration(seconds: 2), () {
                  nextScreen(
                      context,
                      GroupsChatScreen(
                          groupId: groupId,
                          groupName: groupName,
                          userName: userName));
                });
              } else {
                setState(() {
                  isJoined = !isJoined;
                  showSnackBar(context, Colors.red, "Left the group $groupName");
                });
              }
            },
            child: isJoined
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Joined",
                        style: GoogleFonts.ubuntu(color: Colors.white)),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.primaryColor,
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text("Join",
                        style: GoogleFonts.ubuntu(color: Colors.white)),
                  ),
          ),
        ),
      ),
    );
  }
}
