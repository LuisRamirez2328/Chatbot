import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'chatbot.dart'; // Asegúrate de que la ruta sea correcta

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo de la Universidad
              Image.asset(
                'lib/assets/university_logo.jpg',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Error al cargar la imagen');
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Ingeniería en Software',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Programación para Móviles II, B',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Luis Antonio Ramirez Nucamendi',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                '221260',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Botón para ir al repositorio
              ElevatedButton(
                onPressed: () async {
                  final Uri _url = Uri.parse('https://github.com/LuisRamirez2328/Chatbot');
                  try {
                    if (await canLaunchUrl(_url)) {
                      await launchUrl(_url, mode: LaunchMode.externalApplication);
                    } else {
                      throw 'No se pudo abrir $_url';
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                child: const Text('Ver Repositorio'),
              ),
              const SizedBox(height: 10),
              // Botón para ir al Chatbot
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatBotView()),
                  );
                },
                child: const Text('Ir al Chatbot'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
