class Avatar {
  int id;
  String url;

  Avatar({required this.id, required this.url});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      id: json['id'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
    };
  }
}

class UserProfile {
  int id;
  String name;
  String code;
  List<Avatar> avatars;
  String url;

  UserProfile({
    required this.id,
    required this.name,
    required this.code,
    required this.avatars,
    required this.url,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var avatarsFromJson = json['avatars'] as List;
    List<Avatar> avatarsList = avatarsFromJson.map((avatar) => Avatar.fromJson(avatar)).toList();

    return UserProfile(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      avatars: avatarsList,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'avatars': avatars.map((avatar) => avatar.toJson()).toList(),
      'url': url,
    };
  }
}
