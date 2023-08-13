import 'package:chat_app/screens/search/search_on_friends_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/auth_services.dart';
import '../../../services/database_services.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../widgets/widgets.dart';
import '../../widgets/frinds_tile.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  AuthServices authService = AuthServices();
  Stream? friends;

  gettingUserData() async {
    //getting the list of snapshot from stream
    await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserCollection()
        .then((snapshot) {
      setState(() {
        friends = snapshot;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: friends,
        builder: (context, AsyncSnapshot snapshot) {
          // make some checks
          if (snapshot.hasData) {
            if (snapshot.data['friends'] != null) {
              if (snapshot.data['friends'].length != 0) {
                return ListView.builder(
                  itemCount: snapshot.data['friends'].length,
                  itemBuilder: (context, index) {
                    int reverseIndex =
                        snapshot.data['friends'].length - index - 1;
                    return FriendTile(
                      friendId: getId(snapshot.data['friends'][reverseIndex]),
                      friendName:
                          getName(snapshot.data['friends'][reverseIndex]),
                      bio: '',
                    );
                  },
                );
              } else {
                return noFriendsWidget();
              }
            } else {
              return noFriendsWidget();
            }
          } else {
            return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryColor));
          }
        });
  }

  noFriendsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              nextScreen(context, const SearchOnFriendsScreen());
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "You've no friends till now, tap on the add icon to add friend or also search from top search button.",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(),
          )
        ],
      ),
    );
  }
}
