import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/image_list.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUploader extends StatefulWidget {
  final List<String>? initialImageUrls;

  const ImageUploader({super.key, this.initialImageUrls});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final List<File> selectedImages = [];
  final List<String> imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.initialImageUrls != null) {
      for (var url in widget.initialImageUrls!) {
        _downloadAndAddImage(url);
      }
    }
  }

  Future<void> _downloadAndAddImage(String imageUrl) async {
    final imageFile = await _downloadImage(imageUrl);

    if (imageFile != null) {
      setState(() {
        selectedImages.add(imageFile);
        imageUrls.add(imageUrl);
      });
      final imageList = Provider.of<ImageList>(context, listen: false);
      imageList.addImageWithUrl(imageUrl, imageFile);
    }
  }

  Future<File?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final documentDirectory = await getApplicationDocumentsDirectory();
        final fileName = const Uuid().v4(); // 고유한 파일 이름 생성
        final file = File('${documentDirectory.path}/$fileName.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print('Failed to download image.');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final imageList = Provider.of<ImageList>(context, listen: false);

    if (selectedImages.length >= 3) {
      return;
    }

    if (source == ImageSource.gallery) {
      final pickedFiles = await _picker.pickMultiImage();
      for (var file in pickedFiles) {
        if (selectedImages.length < 3) {
          File imageFile = File(file.path);
          setState(() {
            selectedImages.add(imageFile);
            imageUrls.add(imageFile.path); // 파일 경로를 URL 리스트에 추가
          });
          imageList.addImage(imageFile);
        }
      }
    } else {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && selectedImages.length < 3) {
        File imageFile = File(pickedFile.path);
        setState(() {
          selectedImages.add(imageFile);
          imageUrls.add(imageFile.path); // 파일 경로를 URL 리스트에 추가
        });
        imageList.addImage(imageFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageList = Provider.of<ImageList>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xff007DFF),
            borderRadius: BorderRadius.circular(10),
          ),
          height: 40,
          child: TextButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: const Text(
              '이미지 추가',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF4F4F4),
              ),
            ),
          ),
        ),
        if (selectedImages.isNotEmpty) ...[
          const SizedBox(height: 5),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(selectedImages[index]),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            var imageList =
                                Provider.of<ImageList>(context, listen: false);
                            setState(() {
                              var selectedImage = selectedImages[index];
                              var imageUrl = imageUrls[index]; // URL을 가져옴
                              print("selectedImage: $selectedImage");
                              print("imageUrl: $imageUrl");
                              selectedImages.removeAt(index);
                              imageUrls.removeAt(index);
                              imageList.addDeletedImageUrl(
                                  imageUrl); // URL을 삭제 이미지 목록에 추가
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
