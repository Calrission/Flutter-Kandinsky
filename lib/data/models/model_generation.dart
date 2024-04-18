import 'dart:convert';

ModelGeneration modelGenerationFromJson(String str) => ModelGeneration.fromJson(json.decode(str));

String modelGenerationToJson(ModelGeneration data) => json.encode(data.toJson());

class ModelGeneration {
    ModelGeneration({
        required this.images,
        required this.errorDescription,
        required this.uuid,
        required this.censored,
        required this.status,
    });

    List<String>? images;
    String? errorDescription;
    String uuid;
    bool? censored;
    String status;

    factory ModelGeneration.fromJson(Map<dynamic, dynamic> json) => ModelGeneration(
        images: (json["images"] != null) ? List<String>.from(json["images"] as List) : null,
        errorDescription: json["errorDescription"],
        uuid: json["uuid"],
        censored: json["censored"],
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "images": List<dynamic>.from(images?.map((x) => x) ?? []),
        "errorDescription": errorDescription,
        "uuid": uuid,
        "censored": censored,
        "status": status,
    };
}
