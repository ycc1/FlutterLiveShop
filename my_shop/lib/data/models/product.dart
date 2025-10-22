class Product {
  final String id;
  final String title;
  final String description;
  final String image;
  final double price;
  final List<String> gallery;
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    this.gallery = const [],
  });

  /// 兼容不同后端字段命名（id/ID/goodsId、name/title 等）
  factory Product.fromJson(Map<String, dynamic> json) {
    String pickId() => (json['id'] ??
            json['ID'] ??
            json['Id'] ??
            json['goodsId'] ??
            json['goodsID'] ??
            '')
        .toString();

    String pickTitle() => (json['title'] ??
            json['name'] ??
            json['goodsName'] ??
            json['subject'] ??
            '未命名')
        .toString();

    double pickPrice() {
      final v = (json['price'] ??
              json['salePrice'] ??
              json['goodsPrice'] ??
              json['amount'] ??
              json['finalPrice'] ??
              0)
          .toString();
      return double.tryParse(v) ?? 0.0;
    }

    String pickDesc() => (json['description'] ??
            json['spesDesc'] ??
            json['brief'] ??
            json['summary'] ??
            '')
        .toString();

    String pickCover() => (json['image'] ??
            json['img'] ??
            json['cover'] ??
            json['thumbnail'] ??
            json['pic'] ??
            '')
        .toString();

    List<String> pickGallery() {
      final g = json['gallery'] ?? json['images'] ?? json['pics'];
      if (g is List) {
        return g.map((e) => e.toString()).toList();
      }
      // 单图兜底
      final cover = pickCover();
      return cover.isNotEmpty ? [cover] : const <String>[];
    }

    return Product(
      id: pickId(),
      title: pickTitle(),
      price: pickPrice(),
      description: pickDesc(),
      image: pickCover(),
      gallery: pickGallery(),
    );
  }
}
