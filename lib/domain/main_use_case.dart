import 'dart:typed_data';

import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/data/repository/requests.dart';

class MainUseCase {
  void validData(){

  }

  Future<void> generate(
    Function(Uint8List) onGenerate,
    Function(String) onError
  ) async {

  }

  Future<void> getStyles(
    Function(List<ModelStyle>) onGenerate,
    Function(String) onError
  ) async {
    await request(loadStyle, onGenerate, onError);
  }
}