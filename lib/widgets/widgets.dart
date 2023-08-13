import 'package:chat_app/widgets/theme_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'language_bootom_sheet.dart';

var textInoutDecoration = const InputDecoration(
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
);

void showSnackBar(BuildContext context, Color color, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ),
  );
}

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

String getId(String res) {
  return res.substring(0, res.indexOf("_"));
}

String getName(String res) {
  return res.substring(res.indexOf("_") + 1);
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

