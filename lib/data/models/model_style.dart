import 'dart:convert';

ModelStyle modelStyleFromJson(String str) => ModelStyle.fromJson(json.decode(str));

String modelStyleToJson(ModelStyle data) => json.encode(data.toJson());

class ModelStyle {
    ModelStyle({
        required this.image,
        required this.titleEn,
        required this.name,
        required this.title,
    });

    String image;
    String titleEn;
    String name;
    String title;

    factory ModelStyle.fromJson(Map<dynamic, dynamic> json) => ModelStyle(
        image: json["image"],
        titleEn: json["titleEn"],
        name: json["name"],
        title: json["title"],
    );

    Map<dynamic, dynamic> toJson() => {
        "image": image,
        "titleEn": titleEn,
        "name": name,
        "title": title,
    };
}
