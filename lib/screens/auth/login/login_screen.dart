import 'package:chat_app/layout/home_layout.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../helper/helper_functions.dart';
import '../../../services/auth_services.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../widgets/widgets.dart';
import 'package:chat_app/screens/auth/signup/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool isVisible = true;
  bool _isLoading = false;
  AuthServices authServices = AuthServices();
  User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Chatoo",
                          style: GoogleFonts.novaFlat(fontSize: 30.sp)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Text("Login now to see what they are talking!",
                          style: Theme.of(context).textTheme.bodySmall),
                      Image.asset("assets/images/login.png"),
                      TextFormField(
                        validator: (value) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value!)
                              ? null
                              : "Please enter a valid email";
                        },
                        decoration: textInoutDecoration.copyWith(
                            labelText: "Email",
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                            prefixIcon: const Icon(
                              Icons.email,
                              color: AppColors.primaryColor,
                            )),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      TextFormField(
                        validator: (val) {
                          if (val!.length < 6) {
                            return "Password must be at least 6 characters";
                          } else {
                            return null;
                          }
                        },
                        obscureText: isVisible,
                        decoration: textInoutDecoration.copyWith(
                            labelText: "Password",
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: AppColors.primaryColor,
                            ),
                            suffixIcon: InkWell(
                                onTap: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                },
                                child: isVisible
                                    ? const Icon(
                                        Icons.visibility,
                                        color: AppColors.primaryColor,
                                      )
                                    : const Icon(
                                        Icons.visibility_off,
                                        color: AppColors.primaryColor,
                                      ))),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.novaSquare(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Text.rich(
                        TextSpan(
                            text: "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodySmall,
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Sign Up",
                                  style: GoogleFonts.ubuntu(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreenReplace(
                                          context, const SignupScreen());
                                    }),
                            ]),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }


  // login() async {
  //   if (formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await authServices
  //         .signInWithEmailAndPassword(email, password)
  //         .then((value) async {
  //       if (value == true) {
  //         QuerySnapshot snapshot = await DatabaseServices(
  //                 uid: FirebaseAuth.instance.currentUser!.uid)
  //             .gettingUserData(email);
  //         // saving the values to our shared preferences
  //         await HelperFunctions.saveUserLoggedInStatus(true);
  //         await HelperFunctions.saveUserEmailSp(email);
  //         await HelperFunctions.saveUserNameSp(snapshot.docs[0]['fullName']);
  //         nextScreenReplace(context, const HomeLayout());
  //       } else {
  //         showSnackBar(context, Colors.red, value);
  //         setState(() {
  //           _isLoading = false;
  //         });
  //       }
  //     });
  //   }
  // }

login() async {
  if (formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });
    await authServices
        .signInWithEmailAndPassword(email, password)
        .then((value) async {
      if (value == true) {
        QuerySnapshot snapshot = await DatabaseServices(
                uid: FirebaseAuth.instance.currentUser!.uid)
            .gettingUserData(email);
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSp(email);

          // var fullName = (snapshot.data() as Map<String, dynamic>)['fullName'];
          await HelperFunctions.saveUserNameSp(snapshot.docs[0]['fullName'])
              .then((value) {
            nextScreenReplace(context, const HomeLayout());
          });
        } else {
          showSnackBar(context, Colors.red, 'Please verify your email');
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        showSnackBar(context, Colors.red, value);
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}
}
