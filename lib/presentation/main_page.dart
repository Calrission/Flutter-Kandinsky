import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kandinsky_flutter/data/models/model_ai.dart';
import 'package:kandinsky_flutter/data/models/model_style.dart';
import 'package:kandinsky_flutter/domain/main_use_case.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  final GlobalKey _dialogKey = GlobalKey();

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
  ModelAI? modelAI;

  static const double padding = 22;
  double widthImage = 0;

  var promtTextController = TextEditingController();
  var negativePromtTextController = TextEditingController();

  List<ModelStyle> styles = [];
  bool isCensured = false;

  MainUseCase useCase = MainUseCase();

  @override
  void initState() {
    super.initState();
    ratio = rations.entries.first;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      showLoading();

      await useCase.getStyles(
        (styles) {
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

      await useCase.getModelAI(
        (model) {
          setState(() {
            modelAI = model;
            hideLoading();
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
            key: _dialogKey,
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
    if (_dialogKey.currentContext != null) {
      Navigator.pop(context);
    }
  }

  Future<void> pressButtonGenerate() async {
    useCase.pressGenerate(
      widthImage,
      ratio.value,
      promtTextController.text,
      negativePromtTextController.text,
      modelAI,
      style,
      onInit: (id){
        setState(() {
          isCensured = false;
          image = null;
        });
        showLoading();
      },
      onCheckStatus: (status) {

      },
      onDone: (image){
        setState(() {
          this.image = image;
        });
        hideLoading();
      },
      onCensured: (_) {
        setState(() {
          isCensured = true;
        });
        hideLoading();
      },
      onError: (error) {
        hideLoading();
        showError(error);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    widthImage = MediaQuery.of(context).size.width - padding * 2;
    var theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              const SizedBox(height: 48),
              (modelAI == null)
                ? const SizedBox()
                : Text(
                  "${modelAI!.name} v${modelAI!.version}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  )
              ),
              const SizedBox(height: 18),
              Center(
                child: SizedBox(
                  width: widthImage,
                  child: AspectRatio(
                    aspectRatio: ratio.value,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Container(
                        width: double.infinity,
                        color: theme.colorScheme.primary,
                        child: (image != null)
                          ? Image.memory(image!)
                          : (isCensured)
                            ? Transform.scale(
                              scale: 0.85,
                              child: Transform.rotate(
                                angle: 0.45,
                                child: SvgPicture.asset(
                                  "assets/censured.svg",
                                  color: Colors.white
                                ),
                              ),
                            )
                            : const SizedBox()
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
                maxLength: 1000,
                maxLines: null,
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
                maxLength: 1000,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "Негативный промт (опционально)",
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