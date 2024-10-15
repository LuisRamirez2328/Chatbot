import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiKey = "YOUR_API_KEY"; // Reemplaza con tu API key de Google Generative AI

class ChatBotView extends StatefulWidget {
  const ChatBotView({Key? key}) : super(key: key);

  @override
  _ChatBotViewState createState() => _ChatBotViewState();
}

class _ChatBotViewState extends State<ChatBotView> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  late FlutterTts _flutterTts;
  late GenerativeModel _model;
  late ChatSession _chatSession;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;
  bool _isLoading = false; // Estado de carga

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    _flutterTts = FlutterTts();
    _model = GenerativeModel(apiKey: apiKey, model: 'gemini-pro');
    _chatSession = await _model.startChat();
    _loadMessages();

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results.first);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> _loadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedMessages = prefs.getStringList('messages');
    if (savedMessages != null) {
      setState(() {
        _messages.addAll(savedMessages.map((msg) {
          final isUser = msg.startsWith('USER:');
          return ChatMessage(text: msg.substring(5), isUser: isUser);
        }));
      });
    }
  }

  Future<void> _saveMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> messagesToSave = _messages.map((msg) {
      return (msg.isUser ? 'USER:' : 'BOT:') + msg.text;
    }).toList();
    await prefs.setStringList('messages', messagesToSave);
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = ChatMessage(text: _controller.text, isUser: true);
      setState(() {
        _messages.add(userMessage);
        _isLoading = true; // Muestra el indicador de carga
      });

      await _saveMessages();

      try {
        final response = await _chatSession.sendMessage(Content.text(_controller.text));
        final botResponse = response.text ?? "Lo siento, no pude generar una respuesta.";

        final botMessage = ChatMessage(text: botResponse, isUser: false);
        setState(() {
          _messages.add(botMessage);
          _isLoading = false; // Oculta el indicador de carga
        });

        await _speak(botResponse);
      } catch (e) {
        debugPrint("Error al enviar mensaje: $e");
        setState(() {
          _isLoading = false; // Oculta el indicador de carga
        });

        final errorMessage = ChatMessage(text: "Error al procesar el mensaje.", isUser: false);
        setState(() {
          _messages.add(errorMessage);
        });
      }

      _controller.clear();
      await _saveMessages(); // Guarda los mensajes después de enviar
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Bot'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) => _messages[index],
              ),
            ),
            if (_isLoading) // Muestra un indicador de carga
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 8.0),
                    Text('Analizando...', style: TextStyle(fontSize: 16.0)),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: 'Escribe un mensaje',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isConnected ? _sendMessage : null, // Deshabilitar si no hay conexión
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0),
        ),
      ),
    );
  }
}
