import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:touchlesspro_back4app/services/parse_auth_service.dart';

class ImagePickerService {
  // returns a PickedFile object pointing to the image that was picked
  Future<PickedFile> _pickImage({@required ImageSource source}) async {
    return ImagePicker().getImage(source: source);
  }

  // returns url of image uploaded from gallery
  Future<String> uploadParseImage(
      BuildContext context, String uid, String name) async {
    final selectedImage = await _pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      final auth = Provider.of<ParseAuthService>(context, listen: false);
      String url = await auth.setImage(selectedImage, uid, name);
      return url;
    } else {
      return null;
    }
  }
}
