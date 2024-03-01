import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageList extends ChangeNotifier {
  List<dynamic> _selectedImages = [];
  List<dynamic> _imageUrls = [];
  List<dynamic> _deletedImages = [];

  List<dynamic> get selectedImages => _selectedImages;
  List<dynamic> get imageUrls => _imageUrls;
  List<dynamic> get deletedImages => _deletedImages;

  void addImage(File image) {
    _selectedImages.add(image);
    notifyListeners();
  }

  void removeImage(File image) {
    _selectedImages.remove(image);
    _deletedImages.add(image);
    notifyListeners();
  }

  setSelectedImages(List<dynamic> selectedImages) {
    _selectedImages = selectedImages;
  }

  setImageUrls(List<dynamic> imageUrls) {
    _imageUrls = imageUrls;
    notifyListeners();
  }

  void clearDeletedImages() {
    _deletedImages = [];
  }
}
