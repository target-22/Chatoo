import 'package:chat_app/helper/helper_functions.dart';
import 'package:chat_app/screens/auth/login/login_screen.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../shared/styles/app_colors.dart';
import '../../../widgets/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String confirmPassword = "";
  String fullName = "";
  bool isVisible = true;
  bool _isLoading = false;
  AuthServices authServices = AuthServices();

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
                      Text(
                        "Chatoo",
                        style: GoogleFonts.novaFlat(fontSize: 30.sp),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Text(
                        "Create your account now to chat and explore",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Image.asset("assets/images/register.png"),
                      TextFormField(
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Name cannot be empty";
                          }
                        },
                        decoration: textInoutDecoration.copyWith(
                          labelText: "UserName",
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
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
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            email = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      TextFormField(
                        validator: (value) {
                          RegExp regex = RegExp(
                              r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$");
                          if (value!.isEmpty) {
                            return 'Please enter password';
                          } else {
                            if (!regex.hasMatch(value)) {
                              return 'Enter valid password';
                            } else {
                              return null;
                            }
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
                                  ),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            register();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.novaSquare(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: Theme.of(context).textTheme.bodySmall,
                          children: <TextSpan>[
                            TextSpan(
                              text: "Sign In",
                              style: GoogleFonts.ubuntu(
                                color: Colors.blue,
                                fontSize: 18,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  nextScreenReplace(
                                      context, const LoginScreen());
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authServices
          .registerUserEmailAndPassword(fullName, email, password)
          .then((value) async {
        if (value == true) {
          await HelperFunctions.saveUserNameSp(fullName);
          await HelperFunctions.saveUserEmailSp(email);
          showSnackBar(
            context,
            Colors.green,
            "Registration successful! Please check your email for verification.",
          );
          nextScreenReplace(context, const LoginScreen());
        } else {
          showSnackBar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  // sendVerificationEmail() async {
  //   if (formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     try {
  //       // Create user with email and password
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //
  //       await userCredential.user!.sendEmailVerification();
  //       await DatabaseServices(uid: FirebaseAuth.instance.currentUser!.uid)
  //           .savingUserData(fullName, email);
  //       // await HelperFunctions.saveUserLoggedInStatus(true);
  //       await HelperFunctions.saveUserNameSp(fullName);
  //       await HelperFunctions.saveUserEmailSp(email);
  //
  //       nextScreenReplace(context, const LoginScreen());
  //       // Show verification message
  //       showSnackBar(
  //         context,
  //         Colors.green,
  //         "Registration successful! Please check your email for verification.",
  //       );
  //
  //       setState(() {
  //         _isLoading = false;
  //       });
  //
  //       formKey.currentState!.reset();
  //     } catch (error) {
  //       showSnackBar(context, Colors.red, error.toString());
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
}
