import 'dart:convert';

ModelAI modelAiFromJson(String str) => ModelAI.fromJson(json.decode(str));

String modelAiToJson(ModelAI data) => json.encode(data.toJson());

class ModelAI {
    ModelAI({
        required this.name,
        required this.id,
        required this.type,
        required this.version,
    });

    String name;
    int id;
    String type;
    int version;

    factory ModelAI.fromJson(Map<dynamic, dynamic> json) => ModelAI(
        name: json["name"],
        id: json["id"],
        type: json["type"],
        version: json["version"],
    );

    Map<dynamic, dynamic> toJson() => {
        "name": name,
        "id": id,
        "type": type,
        "version": version,
    };
}
