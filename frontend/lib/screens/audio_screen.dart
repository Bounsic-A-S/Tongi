import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/core/tongi_styles.dart';
import 'package:frontend/services/record_service.dart';
import 'package:frontend/widgets/audio/audio_translation.dart';
import 'package:frontend/widgets/language_selector.dart';
import 'package:frontend/widgets/audio/record_button.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  late final RecordService _recordService;

  @override
  void initState() {
    super.initState();
    _recordService = RecordService();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LanguageSelector(),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            border: BoxBorder.all(color: TongiColors.border, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  RecordButton(service: _recordService),
                  SizedBox(height: 15),
                  Text(
                    "Toca para iniciar a grabar.",
                    style: TongiStyles.textBody,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //     border: BoxBorder.all(color: TongiColors.border, width: 1),
        //     borderRadius: BorderRadius.only(
        //       topLeft: Radius.circular(0),
        //       topRight: Radius.circular(0),
        //       bottomLeft: Radius.circular(16),
        //       bottomRight: Radius.circular(16),
        //     ),
        //     color: TongiColors.secondary,
        //   ),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Column(
        //         children: [
        //           SizedBox(height: 10),
        //           IconButton(
        //             onPressed: () {},
        //             icon: Icon(Icons.play_arrow_rounded),
        //             padding: EdgeInsets.all(0),
        //             style: ButtonStyle(
        //               iconColor: WidgetStatePropertyAll(
        //                 TongiColors.lightMainFill,
        //               ),
        //               iconSize: WidgetStatePropertyAll(60),
        //             ),
        //           ),
        //           Text(
        //             "Reproducir audio traducido",
        //             style: TextStyle(
        //               color: Colors.white,
        //               fontFamily: "Poppins",
        //             ),
        //           ),
        //           SizedBox(height: ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        SizedBox(height: 20),
        AudioTranslation(),
      ],
    );
  }
}
