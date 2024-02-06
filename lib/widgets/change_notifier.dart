import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageList extends ChangeNotifier {
  List<File> _selectedImages = [];

  List<File> get selectedImages => _selectedImages;

  void addImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeImage(File image) {
    _selectedImages.remove(image);
    notifyListeners();
  }
}
