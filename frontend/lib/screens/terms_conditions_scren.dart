import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:frontend/core/tongi_colors.dart';
import 'package:frontend/screens/main_screen.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  _TermsConditionsScreenState createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TongiColors.primary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Términos & Condiciones"),
        backgroundColor: TongiColors.primary,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      bottomNavigationBar: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: TongiColors.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
          onPressed: () {
            if (isChecked) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Debes aceptar los términos y condiciones"),
                ),
              );
            }
          },
          child: const Text("Aceptar",
              style: TextStyle(fontSize: 20)),
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/tongiWhite.png",
              height: 200, // aumentado
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value ?? false;
                    });
                  },
                  activeColor: Colors.white,
                  checkColor: TongiColors.secondary,
                  fillColor: MaterialStateProperty.all(Colors.white70),
                ),
                Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(
                              text:
                                  'By checking this you are accepting the terms and conditions of ',
                            ),
                            TextSpan(
                              text: 'Tongi.',
                              style: const TextStyle(
                                color: Colors.amber,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FullTermsScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ); 

  }
}


class FullTermsScreen extends StatelessWidget {
  const FullTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Términos y Condiciones"),
        backgroundColor: TongiColors.primary,
        foregroundColor: Colors.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Text(
            "Aquí van los términos y condiciones completos de Tongi.\n\n"
            "Puedes escribir todo el contenido legal que necesites...",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
