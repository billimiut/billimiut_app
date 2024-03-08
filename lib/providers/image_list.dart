import 'dart:io';
import 'package:flutter/foundation.dart';

class ImageList extends ChangeNotifier {
  List<dynamic> _selectedImages = [];
  List<dynamic> _imageUrls = [];
  final List<dynamic> _deletedImages = [];
  final Map<File, String> _selectedImagesWithUrls = {}; // 파일과 URL을 매핑한 Map
  List<String> _deletedImageUrls = [];

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

/*
  void addDeletedImage(File image) {
    _deletedImages.add(image);
    notifyListeners();
  }
*/
  setSelectedImages(List<dynamic> selectedImages) {
    _selectedImages = selectedImages;
  }

  setImageUrls(List<dynamic> imageUrls) {
    _imageUrls = imageUrls;
    notifyListeners();
  }

  void clearDeletedImages() {
    _deletedImageUrls = [];
  }

  String? getImageUrl(File image) {
    return _selectedImagesWithUrls[image];
  }

  addImageWithUrl(String url, File image) {
    _selectedImagesWithUrls[image] = url;
    notifyListeners();
  }

  void addDeletedImageUrl(String? url) {
    if (url != null) {
      _deletedImageUrls.add(url);
    }
    notifyListeners();
  }

  List<String> getDeletedImageUrls() {
    return _deletedImageUrls;
  }
}
