import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
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
      required Function(String uuid) onInit,
      required Function(String uuid) onCheckStatus,
      required Function(Uint8List bytes) onDone,
      required Function(String uuid) onCensured,
      required Function(String error) onError
    }
  ) async {
    bool isValid = validData(imageWidth, promt, style, modelAI, onNotValid: onError);
    if (!isValid){
      return;
    }
    
    ModelGenerateRequest modelGenerateRequest = ModelGenerateRequest(
      generateParams: GenerateParams(query: promt),
      width: imageWidth.toInt(),
      height: (imageWidth * ratio).toInt(),
      negativePromptUnclip: negativePromt,
      style: style!.name,
      numImages: 1,
    );
    
    String id = "";
    await startGenerate(
      modelGenerateRequest,
      modelAI!,
      onInitGenerate: (String uuid){
        id = uuid;
      },
      onError: onError
    );

    if (id == ""){
      return;
    }

    onInit(id);

    startTimer(Future<void> Function() func){
      Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        await func();
      });
    }

    Future<void> iterationCheck() async {
      await checkGenerate(
        id,
        onDone: (ModelGeneration model){
          var bytes = base64Decode(model.images!.first);
          onDone(bytes);
        },
        onCheckStatus: (status){
          onCheckStatus(status);
          startTimer(iterationCheck);
        },
        onError: onError
      );
    }

    startTimer(iterationCheck);
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