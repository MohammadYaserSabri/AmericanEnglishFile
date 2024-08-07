import 'package:image_picker/image_picker.dart';

class ImagePick {
  Future<XFile?> uploadImage() async {
    ImagePicker imagePicker = ImagePicker();
    return await imagePicker.pickImage(source: ImageSource.gallery);
  }
}