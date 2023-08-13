import 'package:chat_app/screens/search/search_on_friends_screen.dart';
import 'package:chat_app/shared/provider/app_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helper/helper_functions.dart';
import '../screens/chats/friends_screen.dart';
import '../screens/groups/groups_screen.dart';
import '../screens/search/search_on_grops_screen.dart';
import '../services/auth_services.dart';
import '../services/database_services.dart';
import '../shared/styles/app_colors.dart';
import '../widgets/drawer_tile.dart';
import '../widgets/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> with TickerProviderStateMixin {
  AuthServices authService = AuthServices();
  String userName = "";
  String email = "";
  String groupName = "";
  Stream? groups;
  bool _isLoading = false;
  late final TabController _tabController;
  String appBarTitle = "Chats";

  @override
  void initState() {
    super.initState();
    gettingUserData();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    setState(() {
      if (_tabController.index == 0) {
        appBarTitle = AppLocalizations.of(context)!.chats;
      } else {
        appBarTitle = AppLocalizations.of(context)!.groups;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  gettingUserData() async {
    await HelperFunctions.getUserNameFromSp().then((value) {
      setState(() {
        userName = value ?? "";
      });
    });

    await HelperFunctions.getUserEmailFromSp().then((value) {
      setState(() {
        email = value ?? "";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyAppProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                showLanguageSheet(context);
              },
              icon: const Icon(
                Icons.translate,
              )),
          IconButton(
              onPressed: () {
                showThemeSheet(context);
              },
              icon: Icon(
                provider.themeMode == ThemeMode.light ?
                Icons.light_mode
                : Icons.dark_mode ,
              )),
          IconButton(
              onPressed: () {
                _tabController.index == 0
                    ? nextScreen(context, const SearchOnFriendsScreen())
                    : nextScreen(context, const SearchOnGroupsScreen());
              },
              icon: const Icon(
                Icons.search,
              )),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              child: Text("Chats", style:Theme.of(context).textTheme.bodySmall),
            ),
            Tab(
              child: Text("Groups", style:Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
      drawer: const Drawer(
        child: DrawerTile(),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const <Widget>[
              FriendsScreen(),
              GroupsScreen(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  popUpDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                "Create a group",
                textAlign: TextAlign.left,
                style: GoogleFonts.novaFlat(),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isLoading == true
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryColor),
                        )
                      : TextField(
                          onChanged: (value) {
                            setState(() {
                              groupName = value;
                            });
                          },
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(22)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(22)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.primaryColor),
                                  borderRadius: BorderRadius.circular(22))),
                        ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: const Text("CANCEL"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (groupName != "") {
                      setState(() {
                        _isLoading = true;
                      });
                      DatabaseServices(
                              uid: FirebaseAuth.instance.currentUser!.uid)
                          .createGroup(userName,
                              FirebaseAuth.instance.currentUser!.uid, groupName)
                          .whenComplete(() {
                        _isLoading = false;
                      });
                      Navigator.pop(context);
                      showSnackBar(
                          context, Colors.green, "Group created successfully.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor),
                  child: const Text("CREATE"),
                )
              ],
            );
          }));
        });
  }
}
