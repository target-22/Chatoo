import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../shared/provider/app_provider.dart';
import '../widgets/language_bootom_sheet.dart';
import '../widgets/theme_bottom_sheet.dart';

class AboutUs extends StatefulWidget {

  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {


  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<MyAppProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: provider.language == 'en'
              ? Text("About us", style: Theme.of(context).textTheme.bodyMedium)
              : Text("من نحن",
                  style: Theme.of(context).textTheme.bodyMedium),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Center(
                child: Text.rich(TextSpan(children: [
                  provider.language == "en"
                      ? TextSpan(
                          text: "powered by ",
                          style: Theme.of(context).textTheme.bodySmall)
                      : TextSpan(
                          text: "مشغل بواسطة ",
                          style: Theme.of(context).textTheme.bodySmall),
                  provider.language == "en"
                      ? TextSpan(
                          text: "SOLDIER",
                          style: Theme.of(context).textTheme.bodyMedium)
                      : TextSpan(
                          text: "SOLDIER",
                          style: Theme.of(context).textTheme.bodyMedium)
                ])),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Center(
                child: Text.rich(TextSpan(children: [
                  provider.language == "en"
                      ? TextSpan(
                          text: "designed by ",
                          style: Theme.of(context).textTheme.bodySmall)
                      : TextSpan(
                          text: "مصمم بواسطة ",
                          style: Theme.of(context).textTheme.bodySmall),
                  provider.language == "en"
                      ? TextSpan(
                          text: "ُEYO",
                          style: Theme.of(context).textTheme.bodyMedium)
                      : TextSpan(
                          text: "EYO",
                          style: Theme.of(context).textTheme.bodyMedium)
                ])),
              ),
            ],
          ),
        )
    );
  }

  void showLanguageSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return LanguageBottomSheet();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  void showThemeSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ThemeBottomSheet();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0.r),
      ),
    );
  }
}
