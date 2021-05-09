import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_pay/providers/auth.dart';
import 'package:mi_pay/terms_and_condition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'config/save_image.dart';

// ignore: must_be_immutable
class Setting extends StatefulWidget {
  static const routeName = '/settings';
  bool someBool = false;

  Setting(this.someBool);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  File _pickedImage;
  String imageString;
  String userName;
  final _auth = FirebaseAuth.instance;

  void _pickImageCamera() async {
//    ImageSharedPrefs.emptyPrefs();
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    ImageSharedPrefs.saveImageToPrefs(_pickedImage).then((value) async {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(_auth.currentUser.uid + '.jpg');
      await ref.putFile(_pickedImage).then((val) async {
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser.uid)
            .update({
          'image_url': url,
        });
      });
    });
  }

  void _pickImageGallery() async {
//    ImageSharedPrefs.emptyPrefs();
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    ImageSharedPrefs.saveImageToPrefs(_pickedImage).then((value) async {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child(_auth.currentUser.uid + '.jpg');
      await ref.putFile(_pickedImage).then((val) async {
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.currentUser.uid)
            .update({
          'image_url': url,
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    Future(() async {
      imageString = await loadImageFromPrefs();
      userName = await getUsername();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.06, left: 10),
                    child: Center(
                        child: Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: width * 0.078,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.06, left: 10),
                    child: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FutureBuilder(
                      future: loadImageFromPrefs(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('assets/images/placeholder.png'),
                            ),
                          );
                        }

                        if (snapshot.data == null) {
                          loadImageFromPrefs();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  AssetImage('assets/images/placeholder.png'),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.black,
                                backgroundImage: _pickedImage != null
                                    ? FileImage(_pickedImage)
                                    : FileImage(File(snapshot.data)),
                              ),
                            ),
                            FutureBuilder(
                                future: getUsername(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: Text('Loading...'),
                                        ),
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 8, right: 8),
                                        child: Text(
                                          '${snapshot.data}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                            if (width > 400)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  FlatButton.icon(
                                    onPressed: () {
                                      _pickImageCamera();
                                    },
                                    textColor: Colors.black,
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Take a picture',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ),
                                  FlatButton.icon(
                                    onPressed: () async {
                                      _pickImageGallery();
                                    },
                                    textColor: Colors.black,
                                    icon: Icon(
                                      Icons.image_outlined,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Add an Image',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  FlatButton.icon(
                                    onPressed: () {
                                      _pickImageCamera();
                                    },
                                    textColor: Colors.black,
                                    icon: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Take a picture',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ),
                                  FlatButton.icon(
                                    onPressed: () {
                                      _pickImageGallery();
                                    },
                                    textColor: Colors.black,
                                    icon: Icon(
                                      Icons.image_outlined,
                                      color: Colors.black,
                                    ),
                                    label: Text(
                                      'Add an Image',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      }),
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Terms and Conditions',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, TermsAndCondition.routeName);
                    },
                  ),
//                  FlatButton(
//                      onPressed: () async {
//                        await getEcoBank().then((value) async{
//                         await cardPayment(value);
//                        });
//                      },
//                      child: Text('EcoBank'))
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 50,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
            child: Center(
                child: Text('Log Out',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold))),
          ),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            Navigator.of(context).pop();
            Provider.of<Auth>(context, listen: false).setIsVerified(false);
            await prefs.setBool('userVerify',
                Provider.of<Auth>(context, listen: false).isVerify);
            FirebaseAuth.instance.signOut();
            await Future<void>.delayed(
              Duration(seconds: 3),
              () async {
                ImageSharedPrefs.emptyPrefs();
                prefs.remove('userName');
              },
            );
          },
        ),
      ),
    );
  }

  loadImageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imageKeyValue = prefs.getString(IMAGE_KEY);
    if (imageKeyValue != null) {
      imageString = await ImageSharedPrefs.loadImageFromPrefs();
    }
    return imageString;
  }

  getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('userName') != null) {
      userName = prefs.getString('userName');
    }
    return userName;
  }

  static const _apikey = "5218fb9f92mshf5f338c20fee546p125b1djsnf498c408ca48";

  static const String _baseUrl = "developer.ecobank.com";

  static const Map<String, String> _headers = {
    "content-type": "application/json",
    "x-rapidapi-host": _baseUrl,
    "x-rapidapi-key": _apikey
  };

  Future<String> getEcoBank() async {
    const Map<String, String> _headers = {
      "Host": _baseUrl,
      "content-type": "application/json",
      "Accept": "application/json",
      "Origin": _baseUrl
    };

    Uri uri = Uri.https(
      _baseUrl,
      "/corporateapi/user/token",
    );
    http.Response response = await http.post(uri,
        headers: _headers,
        body: json.encode({
          "userId": "iamaunifieddev103",
          "password":
              "\$2a\$10\$Wmame.Lh1FJDCB4JJIxtx.3SZT0dP2XlQWgj9Q5UAGcDLpB0yRYCC",
        }));

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

//      print(json.decode(response.body)['token']);

//       json.decode(response.body.toString());
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load json data');
    }
//    print(json.decode(response.body)['token']);

    return json.decode(response.body)['token'];
  }

  cardPayment(String token) async {
    try {
      Map<String, String> _headers = {
        "Host": _baseUrl,
        "Authorization": "Bearer $token",
        "content-type": "application/json",
        "Accept": "application/json",
        "Origin": _baseUrl
      };

      Uri uri = Uri.https(
        _baseUrl,
        "/corporateapi/merchant/card",
      );
      http.Response response = await http.post(uri,
          headers: _headers,
          body: json.encode({
            "paymentDetails": {
              "requestId": "4466",
              "productCode": "GMT112",
              "amount": "50035",
              "currency": "NGN",
              "locale": "en_AU",
              "orderInfo": "255s353",
              "returnUrl": "https://unifiedcallbacks.com/corporateclbkservice/callback/qr"
            },
            "merchantDetails": {
              "accessCode": "79742570",
              "merchantID": "ETZ001",
              "secureSecret": "sdsffd"
            },
            "secureHash": "85dc50e24f6f36850f48390be3516c518acdc427c5c5113334c1c3f0ba122cdd37b06a10b82f7ddcbdade8d8ab92165e25ea4566f6f8a7e50f3c9609d8ececa4"
          }));

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.

        print(json.decode(response.body)['response_content']);

        return json.decode(response.body.toString());
      } else {
        print('Errr');
        // If that response was not OK, throw an error.
        throw Exception('Failed to load json data');
      }
    }catch(error){
      print(error);
    }
  }

}
