import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_generate_request.dart';
import 'package:kandinsky_flutter/data/models/model_generation.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/data/repository/requests.dart';
import 'package:kandinsky_flutter/domain/utils.dart';

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

    requestStartGeneration() async {
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
    }

    requestToListenStatusChanges() async {
      startListenCheckStatusGeneration(
          id,
          onDone: onDone,
          onCensured: onCensured,
          onError: onError,
          onCheckStatus: onCheckStatus
      );
    }

    await request(requestStartGeneration, onError);
    await request(requestToListenStatusChanges, onError);
  }

  Future<void> startListenCheckStatusGeneration(
    String id,
      {
        required Function(String uuid) onCheckStatus,
        required Function(Uint8List bytes) onDone,
        required Function(String uuid) onCensured,
        required Function(String error) onError
      }
  ) async {
    startDelayed(Future<void> Function() func) async {
      await Future.delayed(const Duration(seconds: 1));
      await func();
    }

    Future<void> iterationCheck() async {
      requestCheckGeneration() async {
        await checkGenerate(
            id,
            onDone: (ModelGeneration model){
              var bytes = base64Decode(model.images!.first);
              if (model.censored ?? false){
                onCensured(id);
                return;
              }
              onDone(bytes);
            },
            onCheckStatus: (status){
              onCheckStatus(status);
              startDelayed(iterationCheck);
            },
            onError: onError
        );
      }
      request(requestCheckGeneration, onError);
    }

    startDelayed(iterationCheck);
  }

  Future<void> getStyles(
    Function(List<ModelStyle>) onGenerate,
    Function(String) onError
  ) async {
    requestFetchStyles() async {
      await fetchStyles(onGenerate, onError);
    }
    request(requestFetchStyles, onError);
  }

  Future<void> getModelAI(
    Function(ModelAI) onResponse,
    Function(String) onError
  ) async {
    requestGetIdModelsAI() async {
      await getIdModelsAI(
              (models){
            onResponse(models.first);
          },
          onError
      );      
    }
    
    await request(requestGetIdModelsAI, onError);
  }
}