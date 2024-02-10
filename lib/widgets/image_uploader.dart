import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../widgets/change_notifier.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({Key? key}) : super(key: key);

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final imageList = Provider.of<ImageList>(context, listen: false);

    if (selectedImages.length >= 3) {
      // 이미지가 3장을 선택한 경우 추가적인 선택을 막음
      return;
    }

    if (source == ImageSource.gallery) {
      //
      final pickedFile = await _picker.pickMultiImage();
      List<XFile> xFilePick = pickedFile ?? <XFile>[];

      if (xFilePick.isNotEmpty) {
        for (var i = 0;
            i < xFilePick.length && selectedImages.length < 3;
            i++) {
          File file = File(xFilePick[i].path);
          selectedImages.add(file);
          imageList.addImage(file);
        }
        setState(() {});
      }
    } else {
      // 카메라 선택 시
      final XFile? pickedCameraFile = await _picker.pickImage(source: source);

      if (pickedCameraFile != null && selectedImages.length < 3) {
        File file = File(pickedCameraFile.path);
        selectedImages.add(file);
        imageList.addImage(file);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageList = Provider.of<ImageList>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          child: const Text(
            '이미지 추가',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.black,
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
                          image: FileImage(
                            File(selectedImages[index].path),
                          ),
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
                          icon: const Center(
                            child: Icon(Icons.close,
                                color: Colors.white, size: 20),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedImages.remove(selectedImages[index]);
                              imageList.removeImage(selectedImages[index]);
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
