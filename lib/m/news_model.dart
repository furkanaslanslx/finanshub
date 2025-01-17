import 'package:hub/m/category_model.dart';

class Blog {
  int id;
  int blogId;
  int bType;
  String elementType;
  String? content;
  String? contentJson;
  String? url;
  String? altText;
  int rowId;

  Blog({
    required this.id,
    required this.blogId,
    required this.bType,
    required this.elementType,
    this.content,
    this.contentJson,
    this.url,
    this.altText,
    required this.rowId,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      blogId: json['blogId'],
      bType: json['bType'],
      elementType: json['elementType'],
      content: json['content'],
      contentJson: json['contentJson'],
      url: json['url'],
      altText: json['altText'],
      rowId: json['rowId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blogId': blogId,
      'bType': bType,
      'elementType': elementType,
      'content': content,
      'contentJson': contentJson,
      'url': url,
      'altText': altText,
      'rowId': rowId,
    };
  }
}

class ContentItem {
  int id;
  String? code;
  String? explanation;
  String header;
  String? contentJson;
  String? user;
  String? userName;
  int userId;
  List<Category>? categories;
  List<Blog>? blogs;
  List<dynamic>? comments; // Yorumlar listesi (şu anda boş)
  String? insertedAt;
  String? updatedAt;
  String? guid;
  String imgUrl;
  String? blogUrl;

  ContentItem({
    required this.id,
    this.code,
    this.explanation,
    required this.header,
    this.contentJson,
    this.user,
    this.userName,
    required this.userId,
    required this.categories,
    required this.blogs,
    required this.comments,
    required this.insertedAt,
    required this.guid,
    required this.imgUrl,
    required this.blogUrl,
    required this.updatedAt,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      code: json['code'],
      explanation: json['explanation'],
      header: json['header'],
      contentJson: json['contentJson'],
      user: json['user'],
      userName: json['userName'],
      userId: json['userId'],
      categories: (json['categories'] as List<dynamic>).map((e) => Category.fromJson(e)).toList(),
      blogs: (json['blogs'] as List<dynamic>?)?.map((e) => Blog.fromJson(e)).toList() ?? [],
      comments: json['comments'] as List<dynamic>? ?? [],
      insertedAt: json['insertedAt'],
      guid: json['guid'],
      imgUrl: json['imgUrl'],
      blogUrl: json['blogUrl'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'explanation': explanation,
      'header': header,
      'contentJson': contentJson,
      'user': user,
      'userName': userName,
      'userId': userId,
      'categories': categories?.map((e) => e.toJson()).toList(),
      'blogs': blogs?.map((e) => e.toJson()).toList(),
      'comments': comments,
      'insertedAt': insertedAt,
      'guid': guid,
      'imgUrl': imgUrl,
      'blogUrl': blogUrl,
      'updatedAt': updatedAt,
    };
  }
}
