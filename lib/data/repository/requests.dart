import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_error.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:http_parser/http_parser.dart';
import 'env_keys.dart';

final dio = Dio();

Future<void> fetchStyles(
  Function(List<ModelStyle>) onResponse,
  Function(String) onError
) async {
  Response response = await dio.get(
      "https://cdn.fusionbrain.ai/static/styles/api"
  );
  List<dynamic> data = response.data;
  var result = data.map((e) => ModelStyle.fromJson(e)).toList();
  onResponse(result);
}

Future<void> getIdModelsAI(
  Function(List<ModelAI>) onResponse,
  Function(String) onError
) async {
  Response response = await dio.get(
      "https://api-key.fusionbrain.ai/key/api/v1/models",
      options: Options(
          headers: fetchHeadersTokens()
      )
  );
  List<dynamic> data = response.data;
  var result = data.map((e) => ModelAI.fromJson(e)).toList();
  if (result.isEmpty){
    onError("Модели AI не найдены");
    return;
  }
  onResponse(result);
}

Future<void> startGenerate(
    ModelGenerateRequest modelGenerateRequest,
    ModelAI modelAI,
    {
      required Function(String uuid) onInitGenerate,
      required Function(String error) onError
    }
) async {
  var jsonParams = jsonEncode(modelGenerateRequest.toJson());
  var formData = FormData.fromMap(
    {
      "model_id": modelAI.id,
      "params": MultipartFile.fromString(
          jsonParams,
          contentType: MediaType("application", "json")
      )
    },
  );

  Response response = await dio.post(
      "https://api-key.fusionbrain.ai/key/api/v1/text2image/run",
      options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: fetchHeadersTokens()
      ),
      data: formData
  );
  Map<String, dynamic> data = response.data;

  onInitGenerate(data["uuid"]);
}

Future<void> checkGenerate(
  String uuid,
  {
    required Function(ModelGeneration) onDone,
    required Function(String status) onCheckStatus,
    required Function(String error) onError
  }
) async {
  Response response = await dio.get(
    "https://api-key.fusionbrain.ai/key/api/v1/text2image/status/$uuid",
    options: Options(
        headers: fetchHeadersTokens()
    ),
  );
  Map<String, dynamic> data = response.data;
  var model = ModelGeneration.fromJson(data);
  switch (model.status) {
    case "INITIAL":
    case "PROCESSING":
      onCheckStatus(model.status);
    case "FAIL":
      onError(model.errorDescription ?? "Ошибка генерации");
    case "DONE":
      if (model.images?.isEmpty ?? true){
        onError("Ошибка получения изображения(ий)");
        return;
      }
      onDone(model);
  }
}