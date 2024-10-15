import 'package:flutter/material.dart';
import 'screens/chatbot.dart'; // Asegúrate de que la ruta sea correcta

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatBotView(), // Cambia aquí a ChatBotView
    );
  }
}
