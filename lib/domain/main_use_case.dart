import 'dart:typed_data';

import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/data/repository/requests.dart';

class MainUseCase {
  bool validData(
    double imageWidth,
    String promt,
    ModelStyle? style,
    ModelAI? modelAI,
    {
      required Function(String) onNotValid
    }
  ){
    if (imageWidth == 0){
      onNotValid("Ошибка в определении ширины экрана, повторите попытку позже!");
      return false;
    }
    if (promt.isEmpty){
      onNotValid("Введите промт!");
      return false;
    }
    if (style == null){
      onNotValid("Выберите стиль!");
      return false;
    }
    if (modelAI == null){
      onNotValid("Выберите AI!");
      return false;
    }
    return true;
  }

  Future<void> pressGenerate(
    double imageWidth,
    double ratio,
    String promt,
    String negativePromt,
    ModelAI? modelAI,
    ModelStyle? style,
    {
      required Function(String uuid) onInitGenerate,
      required Function(String uuid) onProcessingGenerate,
      required Function(Uint8List bytes) onDoneGenerate,
      required Function(String error) onFailGenerate,
      required Function(String uuid) onCensured,
      required Function(String error) onError
    }
  ) async {
    bool isValid = validData(imageWidth, promt, style, modelAI, onNotValid: onError);
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