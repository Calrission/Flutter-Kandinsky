import 'package:dio/dio.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';

final dio = Dio();

Future<List<ModelStyle>> loadStyle() async {
  Response response = await dio.get("https://cdn.fusionbrain.ai/static/styles/api");
  List<dynamic> data = response.data;
  return data.map((e) => ModelStyle.fromJson(e)).toList();
}


Future<void> request<T>(
  Future<T> Function() request,
  Function(T) onResponse,
  Function(String) onError
) async {
  try {
    T response = await request();
    onResponse(response);
  } on DioException catch (e){
    onError(e.toString());
  } on Exception catch (e) {
    onError(e.toString());
  }
}