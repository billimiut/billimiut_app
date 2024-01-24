class Post {
  final String title;
  final String item;
  final int money;
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final bool borrow;
  final String imageUrl;
  final String description;

  Post({
    required this.title,
    required this.item,
    required this.money,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.borrow,
    required this.imageUrl,
    required this.description,
  });
  /*
  factory Post.fromJson(Map<String, dynamic> json) {
    final volumnInfo = json['volumeInfo'];
    final title = volumnInfo['title'] ?? '';
    final item = volumnInfo['item'] ?? '';
    final money = volumnInfo['money'] ?? '';
    final startDate = volumnInfo['startDate'] ?? '';
    final endDate = volumnInfo['endDate'] ?? '';
    final location = volumnInfo['location'] ?? '';
    final borrow = volumnInfo['borrow'] ?? '';
    final imageUrl = volumnInfo['imageUrl'] ?? '';
    final description = volumnInfo['description'] ?? '';
    return Post(
        title: title,
        item: item,
        money: money,
        startDate: startDate,
        endDate: endDate,
        location: location,
        borrow: borrow,
        imageUrl: imageUrl,
        description: description);
  }
  static fromMap(Map<dynamic, dynamic> postvalue) {
    var title = postvalue['title'] ?? '';
    var item = postvalue['item'] ?? '';
    var money = postvalue['money'] ?? '';
    var startDate = postvalue['startDate'] ?? '';
    var endDate = postvalue['endDate'] ?? '';
    var location = postvalue['location'] ?? '';
    var borrow = postvalue['borrow'] ?? '';
    var imageUrl = postvalue['imageUrl'] ?? '';
    var description = postvalue['description'] ?? '';
    return Post(
        title: title,
        item: item,
        money: money,
        startDate: startDate,
        endDate: endDate,
        location: location,
        borrow: borrow,
        imageUrl: imageUrl,
        description: description);
  }
  */
}
