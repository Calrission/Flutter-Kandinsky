import 'dart:convert';

ModelGenerateRequest modelGenerateRequestFromJson(String str) => ModelGenerateRequest.fromJson(json.decode(str));

String modelGenerateRequestToJson(ModelGenerateRequest data) => json.encode(data.toJson());

class ModelGenerateRequest {
    ModelGenerateRequest({
        required this.generateParams,
        required this.width,
        required this.negativePromptUnclip,
        required this.style,
        required this.numImages,
        required this.height,
    });

    GenerateParams generateParams;
    int width;
    String negativePromptUnclip;
    String style;
    int numImages;
    int height;

    factory ModelGenerateRequest.fromJson(Map<dynamic, dynamic> json) => ModelGenerateRequest(
        generateParams: GenerateParams.fromJson(json["generateParams"]),
        width: json["width"],
        negativePromptUnclip: json["negativePromptUnclip"],
        style: json["style"],
        numImages: json["num_images"],
        height: json["height"],
    );

    Map<dynamic, dynamic> toJson() => {
        "generateParams": generateParams.toJson(),
        "width": width,
        "negativePromptUnclip": negativePromptUnclip,
        "style": style,
        "type": "GENERATE",
        "num_images": numImages,
        "height": height,
    };
}

class GenerateParams {
    GenerateParams({
        required this.query,
    });

    String query;

    factory GenerateParams.fromJson(Map<dynamic, dynamic> json) => GenerateParams(
        query: json["query"],
    );

    Map<dynamic, dynamic> toJson() => {
        "query": query,
    };
}
