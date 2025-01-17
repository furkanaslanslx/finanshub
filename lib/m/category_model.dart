class Category {
  int id;
  String? name;
  String? taxonomy;
  String? tags;
  String? explanation;
  int? rowId;
  String? imgUrl;

  Category({
    required this.id,
    this.name,
    this.taxonomy,
    this.tags,
    this.explanation,
    this.rowId,
    this.imgUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      taxonomy: json['taxonomy'],
      tags: json['tags'],
      explanation: json['explanation'],
      rowId: json['rowId'],
      imgUrl: json['imgUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'taxonomy': taxonomy,
      'tags': tags,
      'explanation': explanation,
      'rowId': rowId,
      'imgUrl': imgUrl,
    };
  }
}
