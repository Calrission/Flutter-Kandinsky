import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';

final dio = Dio();


Future<void> tryOnCatch(
  Future<void> Function() func,
  Function(String) onError
) async {
  try{
    await func();
  } on DioException catch (e){
    if (e.response != null) {
      onError(
          "STATUS: ${e.response?.statusCode}\n"
          "MESSAGE: ${e.response?.statusMessage}"
      );
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