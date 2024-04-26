import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kandinsky_flutter/domain/message_exception.dart';
import 'env_keys.dart';

final dio = Dio();

Future<void> fetchStyles(
  Function(List<ModelStyle>) onResponse
) async {
  Response response = await dio.get(
      "https://cdn.fusionbrain.ai/static/styles/api"
  );
  List<dynamic> data = response.data;
  var result = data.map((e) => ModelStyle.fromJson(e)).toList();
  onResponse(result);
}

Future<void> getModelsAI(
  Function(List<ModelAI>) onResponse
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
    throw const MessageException("Модели AI не найдены");
  }
  onResponse(result);
}

Future<void> startGenerate(
    ModelGenerateRequest modelGenerateRequest,
    ModelAI modelAI,
    {
      required Function(String uuid) onInitGenerate
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
    required Function(String status) onCheckStatus
  }
) async {
  Response response = await dio.get(
    "https://api-key.fusionbrain.ai/key/api/v1/text2image/status/$uuid",
    options: Options(
        headers: fetchHeadersTokens()
    ),
  );
  var model = ModelGeneration.fromJson(response.data);
  switch (model.status) {
    case "INITIAL":
    case "PROCESSING":
      onCheckStatus(model.status);
    case "FAIL":
      throw MessageException(model.errorDescription ?? "Ошибка генерации");
    case "DONE":
      if (model.images?.isEmpty ?? true){
        throw const MessageException("Ошибка получения изображения(ий)");
      }
      onDone(model);
  }
}