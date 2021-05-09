import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mi_pay/config/helpers.dart';
import 'package:mi_pay/config/save_image.dart';
import 'package:mi_pay/providers/transactions.dart';
import 'package:mi_pay/screens/send_money.dart';
import 'package:path/path.dart' as p;
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings.dart';
import 'balance.dart';
import 'bank_card.dart';

class Pay extends StatefulWidget {
  @override
  _PayState createState() => _PayState();
}

class _PayState extends State<Pay> with WidgetsBindingObserver {
  String _scanBarcode = 'Unknown';
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _renderObjectKey = new GlobalKey();
  var auth = FirebaseAuth.instance;
  String imageString;

  startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#000000", "Close", true, ScanMode.BARCODE)
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#000000", "Close", true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
      if (_scanBarcode != '-1') {
        var checkQrcode = false;

        checkQrcode =
            int.tryParse(_scanBarcode.substring(_scanBarcode.length - 3)) >
                    100 &&
                int.tryParse(_scanBarcode.substring(_scanBarcode.length - 3)) <
                    1000;
        if (checkQrcode == true) {
          Navigator.of(context).push(_createRouteSendMoney(_scanBarcode));
        } else {
          Helpers.showMessage('Not a valid QrCode',_scaffoldKey);
        }
      }
    });
  }

  Timer _timer;

  int randomDigit;

  void startTimer() {
    var range = new Random();
    _timer = new Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        randomDigit = range.nextInt(800) + 100;
      });
    });
  }

  var userID;

  @override
  void initState() {
    userID = auth.currentUser.uid;
//    final fbm  = FirebaseMessaging();
    startTimer();
    file('profile.png');
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        key: _scaffoldKey,
        body: Container(
          height: height,
          color: Color(0xFFF9F9F9),
          child: SingleChildScrollView(
              child: Center(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: height * 0.05, left: 10),
                    child: Center(
                        child: Text(
                      'Collect',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: width*0.078,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: IconButton(
                                icon: Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.black,
                                ),
                                onPressed: () => scanQR()),
                          ),
                          Text(
                            'Pay',
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: IconButton(
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.black,
                                ),
                                onPressed: () async {
                                  Provider.of<Transactions>(context,
                                          listen: false)
                                      .fetchTransactions();
                                  Navigator.pushNamed(
                                      context, Setting.routeName,
                                      arguments: true);
                                }),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              'Settings',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.015,
              ),
              Card(
                  elevation: 0,
                  child: Container(
                    color: Color(0xFFF9F9F9),
                    width: width,
                    child: Column(children: [
                      SizedBox(
                        height: height * 0.015,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BarcodeWidget(
                          style: TextStyle(color: Color(0xFFF9F9F9)),
                          barcode: Barcode.code128(),
                          data: 'MiPay',
                          width: width,
                          height: height * 0.15,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.03,
                      ),
                      RepaintBoundary(
                        key: _renderObjectKey,
                        child: FutureBuilder(
                            future: auth.currentUser.reload(),
                            builder: (ctx, snapshot) {
                              return Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Container(
                                  color: Colors.black,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Container(
                                          color: Colors.black,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              BarcodeWidget(
                                                color: Color(0xFFF9F9F9),
                                                barcode: Barcode.qrCode(
                                                  errorCorrectLevel:
                                                      BarcodeQRCorrectionLevel
                                                          .high,
                                                ),
                                                data: '$userID$randomDigit',
                                                width: height * 0.32,
                                                height: height * 0.32,
                                              ),
                                              FutureBuilder(
                                                  future: loadImageFromPrefs(),
                                                  builder: (context, snapshot) {
                                                    if (!snapshot.hasData) {
                                                      return Container(
                                                        height: width * 0.15,
                                                        width: width * 0.15,
                                                        color: Colors.black,
                                                        padding:
                                                        EdgeInsets.all(3.0),
                                                        child: FittedBox(
                                                          fit: BoxFit.cover,
                                                          child: Image(
                                                            image: AssetImage('assets/images/placeholder.png'),
                                                          ),
                                                        ),
                                                      );
                                                    }

                                                    if (snapshot.data == null) {
                                                      loadImageFromPrefs();
                                                      return Container(
                                                        height: width * 0.15,
                                                        width: width * 0.15,
                                                        color: Colors.black,
                                                        padding:
                                                        EdgeInsets.all(3.0),
                                                        child: FittedBox(
                                                          fit: BoxFit.cover,
                                                          child: Image(
                                                            image: AssetImage('assets/images/placeholder.png'),
                                                          ),
                                                        ),
                                                      );
                                                    }

                                                    if (imageString != null) {
                                                      return Container(
                                                        height: width * 0.15,
                                                        width: width * 0.15,
                                                        color: Colors.black,
                                                        padding:
                                                            EdgeInsets.all(3.0),
                                                        child: FittedBox(
                                                          fit: BoxFit.cover,
                                                          child: Image(
                                                            image: FileImage(
                                                                File(snapshot
                                                                    .data)),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return Container(
                                                      height: width * 0.15,
                                                      width: width * 0.15,
                                                      color: Colors.black,
                                                      padding:
                                                      EdgeInsets.all(3.0),
                                                      child: FittedBox(
                                                        fit: BoxFit.cover,
                                                        child: Image(
                                                          image: AssetImage('assets/images/placeholder.png'),
                                                        ),
                                                      ),
                                                    );
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'MiPay',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      if (Platform.isIOS)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      icon: Icon(Icons.share_outlined),
                                      onPressed: () {
                                        _getWidgetImage('$userID$randomDigit');
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Text('Save or Share QrCode'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
//                        mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      icon: Icon(Icons.share_outlined),
                                      onPressed: () {
                                        _getWidgetImage('$userID$randomDigit');
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Text('Share QrCode'),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: IconButton(
                                      icon: Icon(Icons.download_outlined),
                                      onPressed: () {
                                        _takePhoto('$userID$randomDigit');
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Text('Save'),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
//                    Divider(),
                      GestureDetector(
                        child: Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.insert_chart_outlined,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Transaction History')),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(Helpers.createRouteTransaction(0));
                        },
                      ),
                    ]),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(top: height * 0.03, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.black,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                    child: Text(
                                  'My Balance',
                                  style: TextStyle(color: Colors.white,fontSize:  width * 0.04),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(_createRoute());
                      },
                    ),
                    InkWell(
                      child: Padding(
                        padding: EdgeInsets.only(top: height * 0.03, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.black,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Center(
                                    child: Text(
                                  'My Bank Cards',
                                  style: TextStyle(color: Colors.white,fontSize:  width * 0.04 ),
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        print(height);
                        print(width);
                        Navigator.of(context).push(_createRouteBank());
                      },
                    ),
                  ],
                ),
              ),
            ]),
          )),
        ),
      ),
    );
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Balance(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  Route _createRouteBank() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => BankCard(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }



  Route _createRouteSendMoney(String barcodeScanResults) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          SendMoney(barcodeScanResults),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // ignore: missing_return
  Future<Uint8List> _getWidgetImage(String _dataString) async {
    try {
      RenderRepaintBoundary boundary =
          _renderObjectKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.file(_dataString, '$_dataString.png', pngBytes, 'image/png');
      var bs64 = base64Encode(pngBytes);
      debugPrint(bs64.length.toString());
      return pngBytes;
    } catch (exception) {
      print(exception);
    }
  }

  void _takePhoto(String _dataString) async {
    int randomDigit;
    var range = new Random();
    randomDigit = range.nextInt(1000000) + 1;
    RenderRepaintBoundary boundary =
        _renderObjectKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    var pngBytes = byteData.buffer.asUint8List();
    final tempDir = await getTemporaryDirectory();
    final file =
        await new File('${tempDir.path}/image$randomDigit.png').create();
    await file.writeAsBytes(pngBytes).then((value) {
      GallerySaver.saveImage(value.path, albumName: 'MiPay')
          .then((bool success) {});
    });
  }

  loadImageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final imageKeyValue = prefs.getString(IMAGE_KEY);
    if (imageKeyValue != null) {
      imageString = await ImageSharedPrefs.loadImageFromPrefs();
    }
    return imageString = await ImageSharedPrefs.loadImageFromPrefs();
  }

  Future<void> file(String filename) async {
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = p.join(dir.path, filename);
    var file;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser.uid)
        .get()
        .then((val) async {
      final response = await http.get(val['image_url']);
      file = File(pathName);
      file.writeAsBytesSync(response.bodyBytes);
    });
    return ImageSharedPrefs.saveImageToPrefs(file);
  }
}
