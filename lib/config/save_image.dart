import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const IMAGE_KEY = 'IMAGE_KEY';

class ImageSharedPrefs {
  static Future<bool> saveImageToPrefs(File image) async {
    String customImageFile = '';
    SharedPreferences prefs = await SharedPreferences.getInstance();
     customImageFile = image.toString();
      customImageFile = customImageFile.substring(6);
    customImageFile = customImageFile.replaceAll("'", "");
    return await prefs.setString(IMAGE_KEY, customImageFile);
  }


  static Future<bool> emptyPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(IMAGE_KEY);
  }

  static Future<String> loadImageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(IMAGE_KEY);
  }

  // encodes bytes list as string
  static String base64String(Uint8List data) {
    return base64Encode(data);
  }

  // decode bytes from a string
  static imageFrom64BaseString(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }
}