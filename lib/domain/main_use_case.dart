import 'dart:typed_data';

import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/data/repository/requests.dart';

class MainUseCase {
  bool validData(
    String promt,
    {
      required Function(String) onNotValid
    }
  ){
    if (promt.isEmpty){
      onNotValid("Введите промт!");
      return false;
    }
    return true;
  }

  Future<void> pressGenerate(
    double imageWidth,
    double ratio,
    String promt,
    String negativePromt,
    String style,
    Function(Uint8List) onGenerate,
    Function(String) onError
  ) async {
    bool isValid = validData(promt, onNotValid: onError);
    if (!isValid){
      return;
    }
  }

  Future<void> getStyles(
    Function(List<ModelStyle>) onGenerate,
    Function(String) onError
  ) async {
    await requestLoadStyle(onGenerate, onError);
  }

  Future<void> getModelAI(
    Function(ModelAI) onResponse,
    Function(String) onError
  ) async {
    await requestGetIdModelsAI(
      (models){
         onResponse(models.first);
      },
      onError
    );
  }
}