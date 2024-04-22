

import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_error.dart';


var codeToDescription = {
  401: "Ошибка авторизации",
  404: "Ресурс не найден",
  400: "Неверные параметры запроса или текстовое описание слишком длинное",
  500: "Ошибка сервера при выполнении запроса",
  415: "Формат содержимого не поддерживается сервером"
};

Future<void> request(
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