import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_error.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';

import 'env_keys.dart';

final dio = Dio();

var codeToDescription = {
  401: "Ошибка авторизации",
  404: "Ресурс не найден",
  400: "Неверные параметры запроса или текстовое описание слишком длинное",
  500: "Ошибка сервера при выполнении запроса",
  415 : "Формат содержимого не поддерживается сервером"
};

Future<void> tryOnCatch(
  Future<void> Function() func,
  Function(String) onError
) async {
  try{
    await func();
  } on DioException catch (e){

    try{
      if (e.response?.data != null){
        var modelError = ModelError.fromJson(e.response!.data!);
        onError(modelError.message);
      }
    }catch(_){
      var code = e.response?.statusCode;
      if (e.response != null) {
        if (e.response!.statusCode != null && codeToDescription.containsKey(code)){
          onError(codeToDescription[code]!);
        }else{
          onError(
              "STATUS: $code\n"
              "MESSAGE: ${e.response?.statusMessage}"
          );
        }
      } else {
        onError("Ошибка при отправке запроса");
      }
    }

  } catch (e) {
    onError(e.toString());
  }
}

Future<void> requestLoadStyle(
  Function(List<ModelStyle>) onResponse,
  Function(String) onError
) async {
  await tryOnCatch(
    () async {
      Response response = await dio.get(
          "https://cdn.fusionbrain.ai/static/styles/api"
      );
      List<dynamic> data = response.data;
      var result = data.map((e) => ModelStyle.fromJson(e)).toList();
      onResponse(result);
    },
    onError
  );
}

Future<void> requestGetIdModelsAI(
  Function(List<ModelAI>) onResponse,
  Function(String) onError
) async {
  await tryOnCatch(
    () async {
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
    },
    onError
  );
}

Future<void> startGenerate(
    ModelGenerateRequest modelGenerateRequest,
    ModelAI modelAI,
    {
      required Function(String uuid) onInitGenerate,
      required Function(String error) onError
    }
) async {
  await tryOnCatch(
    () async {
      var formData = FormData.fromMap(
        {
          "model_id": modelAI.id,
          "params": jsonEncode(modelGenerateRequest.toJson())
        }
      );
      Response response = await dio.post(
        "https://api-key.fusionbrain.ai/key/api/v1/text2image/run",
        options: Options(
          contentType: Headers.jsonContentType,
          headers: fetchHeadersTokens()
        ),
        data: formData
      );
      Map<String, dynamic> data = response.data;
      onInitGenerate(data["uuid"]);
    },
    onError
  );
}

Future<void> checkGenerate(
  String uuid,
  {
    required Function(ModelGeneration) onDone,
    required Function(String status) onCheckStatus,
    required Function(String error) onError
  }
) async {
  tryOnCatch(
    () async {
      Response response = await dio.get(
          "https://api-key.fusionbrain.ai/key/api/v1/text2image/status/$uuid"
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
    },
    onError
  );
}