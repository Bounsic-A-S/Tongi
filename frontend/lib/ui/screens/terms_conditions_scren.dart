import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:frontend/ui/core/tongi_colors.dart';
import 'package:frontend/ui/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  fillColor: WidgetStateProperty.all(Colors.white70),
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

    Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'induismo97@gmail.com', // 👈 aquí el mail de soporte
      query: Uri.encodeFull(
        'subject=Soporte Tongi&body=Hola equipo Tongi, necesito ayuda con...',
      ),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Términos y Condiciones"),
        backgroundColor: TongiColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
              "assets/images/tongiWhite.png",
              height: 200, // aumentado
              color: Colors.black,
            ),
              Text(
                "Términos y Condiciones de Tongi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Fecha de última actualización: 01 de octubre de 2025",
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Bienvenido a Tongi, la aplicación móvil diseñada para traducir audios y voces de manera rápida y eficiente. "
                "Al descargar, instalar o utilizar nuestra aplicación, usted acepta cumplir plenamente con los presentes Términos y Condiciones. "
                "Si no está de acuerdo con alguno de los términos aquí descritos, le solicitamos que no utilice la App.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "1. Introducción y Alcance",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Tongi ha sido desarrollada con el objetivo de brindar una experiencia de traducción de voz sencilla, confiable y segura. "
                "Nuestra App no recopila datos personales, protegiendo la privacidad de quienes la utilizan. "
                "La información que se procesa dentro de la aplicación es transaccional y voluntaria, es decir, depende de los audios y voces que usted decida cargar para su traducción.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "2. Uso de la Aplicación",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "La App ofrece servicios de traducción de audios y voces entre múltiples idiomas. "
                "Su uso está destinado exclusivamente para fines personales y no comerciales, salvo autorización expresa de Tongi.\n\n"
                "Al utilizar la App, usted se compromete a no emplearla para actividades ilegales, distribución de contenidos difamatorios o discriminatorios, "
                "ni interferir con el funcionamiento de la App.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "3. Privacidad y Acceso a Datos",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "La privacidad de nuestros usuarios es fundamental. Tongi no recopila datos personales como nombre, correo electrónico, ubicación o contactos. "
                "Los accesos de la App están limitados y controlados por el usuario: micrófono (solo para traducción) y almacenamiento (solo para guardar resultados). "
                "Los audios y voces cargados son utilizados únicamente para la funcionalidad de traducción y no se almacenan permanentemente, salvo que el usuario decida conservarlos.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "4. Propiedad Intelectual",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Todos los elementos de Tongi, incluyendo software, interfaces, marcas, logotipos, textos y demás contenidos, son propiedad exclusiva de Tongi o de sus licenciantes. "
                "Queda estrictamente prohibida su reproducción, distribución, modificación o uso no autorizado.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "5. Limitación de Responsabilidad",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Tongi se proporciona “tal cual” y “según disponibilidad”. No podemos garantizar la ausencia total de errores, interrupciones o resultados inexactos en la traducción. "
                "El usuario acepta que la App no será responsable de daños derivados del uso de la App o de la confianza en la información traducida.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "6. Modificaciones y Actualizaciones",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Tongi se reserva el derecho de modificar, actualizar o mejorar la App y estos Términos y Condiciones en cualquier momento. "
                "El uso continuado de la App tras la publicación de cambios constituye la aceptación de los nuevos términos.",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                "7. Contacto",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Para consultas relacionadas con estos Términos y Condiciones, privacidad o funcionamiento de la App, puede contactarnos a través de:",
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: () => _launchEmail(),
                  child: Text(
                    "induismo97@gmail.com",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: TongiColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

