import 'dart:convert';

ModelError modelErrorFromJson(String str) => ModelError.fromJson(json.decode(str));

String modelErrorToJson(ModelError data) => json.encode(data.toJson());

class ModelError {
    ModelError({
        required this.path,
        required this.error,
        required this.message,
        required this.timestamp,
        required this.status,
    });

    String path;
    String error;
    String message;
    DateTime timestamp;
    int status;

    factory ModelError.fromJson(Map<dynamic, dynamic> json) => ModelError(
        path: json["path"],
        error: json["error"],
        message: json["message"],
        timestamp: DateTime.parse(json["timestamp"]),
        status: json["status"],
    );

    Map<dynamic, dynamic> toJson() => {
        "path": path,
        "error": error,
        "message": message,
        "timestamp": timestamp.toIso8601String(),
        "status": status,
    };
}
