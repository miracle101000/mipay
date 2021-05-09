import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_pay/config/save_image.dart';


class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;

  UserImagePicker(this.imagePickFn);

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

  void _pickImageCamera() async {
    ImageSharedPrefs.emptyPrefs();
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    ImageSharedPrefs.saveImageToPrefs(_pickedImage);
    widget.imagePickFn(pickedImageFile);
  }

  void _pickImageGallery() async {
    ImageSharedPrefs.emptyPrefs();
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
    ImageSharedPrefs.saveImageToPrefs(_pickedImage);
    widget.imagePickFn(pickedImageFile);
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.black,
          backgroundImage:
              _pickedImage != null ? FileImage(_pickedImage) : AssetImage('assets/images/placeholder.png'),
        ),
        if(width > 400)
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
                style: TextStyle(color: Colors.black, fontSize: 12),
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
                style: TextStyle(color: Colors.black, fontSize: 12),
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
                textColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black,
                ),
                label: Text(
                  'Take a picture',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
              FlatButton.icon(
                onPressed: () {
                  _pickImageGallery();

                },
                textColor: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.image_outlined,
                  color: Colors.black,
                ),
                label: Text(
                  'Add an Image',
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
