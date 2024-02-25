import 'package:billimiut_app/providers/select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesDropDown extends StatefulWidget {
  const CategoriesDropDown({
    super.key,
  });

  @override
  _CategoriesDropDownState createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  final List<String> categories = [
    '디지털기기',
    '생활가전',
    '가구/인테리어',
    '여성용품',
    '일회용품',
    '생활용품',
    '주방용품',
    '캠핑용품',
    '애완용품',
    '스포츠용품',
    '공부용품',
    '놀이용품',
    '무료나눔',
    '의류',
    '공구',
    '식물',
  ];

  // int selectedIndex = -1;
  // String selectedCategory = "카테고리 선택";
  bool _isClicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Select select = Provider.of<Select>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isClicked = !_isClicked;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: const Color(0xFFF4F4F4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  select.selectedCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 32,
                  color: Color(0xFFFFB900),
                ),
              ],
            ),
          ),
        ),
        Visibility(
          visible: _isClicked,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            height: 200, // 원하는 높이로 조절
            child: ListView.builder(
              itemCount: (categories.length / 5).ceil(),
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: categories
                      .skip(index * 5)
                      .take(5)
                      .map((category) => GestureDetector(
                            onTap: () {
                              setState(() {
                                select.setSelectedIndex(
                                    categories.indexOf(category));
                                select.setSelectedCategory(category);
                                _isClicked = !_isClicked;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                                horizontal: 10.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                color: select.selectedIndex ==
                                        categories.indexOf(category)
                                    ? const Color(0xFFFFB900)
                                    : Colors.transparent,
                              ),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
