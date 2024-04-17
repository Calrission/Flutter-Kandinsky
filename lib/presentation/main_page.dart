import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/domain/main_use_case.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  Uint8List? image;

  Map<String, double> rations = {
    "1 : 1": 1/1,
    "2 : 3": 2/3,
    "3 : 2": 3/2,
    "9 : 16": 9/16,
    "16 : 9" : 16/9
  };

  late MapEntry<String, double> ratio;
  ModelStyle? style;

  static const double padding = 22;

  var promtTextController = TextEditingController();
  var negativePromtTextController = TextEditingController();

  List<ModelStyle> styles = [];

  MainUseCase useCase = MainUseCase();

  @override
  void initState() {
    super.initState();
    ratio = rations.entries.first;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showLoading();
      useCase.getStyles(
        (styles) {
          hideLoading();
          setState(() {
            this.styles = styles;
            style = this.styles.first;
          });
        },
        (error) {
          hideLoading();
          showError(error);
        }
      );
    });
  }

  void showError(String error){
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text("Ошибка!"),
      content: Text(error),
      actions: [
        TextButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          child: const Text("OK")
      )
      ],
    ));
  }

  void showLoading(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: Dialog(
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            child: Center(
                child: Transform.scale(
                  scale: 1.5,
                  child: const CircularProgressIndicator()
                )
            ),
          ),
        );
      }
    );
  }

  void hideLoading(){
    Navigator.pop(context);
  }

  Future<void> pressButtonGenerate() async {

  }

  @override
  Widget build(BuildContext context) {
    var widthImage = MediaQuery.of(context).size.width - padding * 2;
    var theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              const SizedBox(height: 78),
              Center(
                child: SizedBox(
                  width: widthImage,
                  child: AspectRatio(
                    aspectRatio: ratio.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: (image != null)
                        ? Image.memory(image!)
                        : Container(
                            width: double.infinity,
                            color: theme.colorScheme.primary
                          ),
                    )
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Text("Отношение сторон"),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(ratio.key)
                    )
                  ),
                  PopupMenuButton<MapEntry<String, double>>(
                    padding: EdgeInsets.zero,
                    onSelected: (MapEntry<String, double> mapEntry){
                      setState(() {
                        ratio = mapEntry;
                      });
                    },
                    itemBuilder: (context) => rations.keys.map(
                      (e) => PopupMenuItem<MapEntry<String, double>>(
                        value: MapEntry(e, rations[e]!),
                        child: Text(e),
                      ),
                    ).toList()),
                ],
              ),
              Row(
                children: [
                  const Text("Стиль"),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text((style != null) ? style!.title : "")
                    )
                  ),
                  PopupMenuButton<ModelStyle>(
                    padding: EdgeInsets.zero,
                    onSelected: (ModelStyle style){
                      setState(() {
                        this.style = style;
                      });
                    },
                    itemBuilder: (context) => styles.map(
                      (e) => PopupMenuItem<ModelStyle>(
                        value: e,
                        child: Text(e.title),
                      ),
                    ).toList())
                ],
              ),
              TextField(
                controller: promtTextController,
                decoration: const InputDecoration(
                  hintText: "Промт",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal
                  )
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: negativePromtTextController,
                decoration: const InputDecoration(
                    hintText: "Негативный промт",
                    hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal
                    )
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: pressButtonGenerate,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                    )
                  ),
                  child: const Text("Сгенерировать"),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}