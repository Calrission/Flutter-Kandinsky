import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';

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
    if (e.response != null) {
      if (e.response!.statusCode != null && codeToDescription.containsKey(e.response!.statusCode!)){
        onError(codeToDescription[e.response!.statusCode!]!);
      }else{
        onError(
          "STATUS: ${e.response?.statusCode}\n"
          "MESSAGE: ${e.response?.statusMessage}"
        );
      }
    } else {
      onError("Ошибка при отправке запроса");
    }
  } on Exception catch (e) {
    onError(e.toString());
  }
}

Future<void> requestLoadStyle(
  Function(List<ModelStyle>) onResponse,
  Function(String) onError
) async {
  tryOnCatch(
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
  tryOnCatch(
    () async {
      Response response = await dio.get(
          "https://api-key.fusionbrain.ai/key/api/v1/models"
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
    Function(String uuid) onInitGenerate,
    Function(String error) onError
) async {

}

Future<void> checkGenerate(
  String uuid,
  Function(String status) onCheckStatus,
  Function(String error) onError
) async {
  tryOnCatch(
    () async {
      Response response = await dio.get(
          "https://api-key.fusionbrain.ai//key/api/v1/text2image/status/$uuid"
      );
      Map<String, dynamic> data = response.data;
      onCheckStatus(data["status"]);
    },
    onError
  );
}

Future<void> fetchGenerate(
  String uuid,
  Function(ModelGeneration) onFetch,
  Function(String) onError
) async {

}