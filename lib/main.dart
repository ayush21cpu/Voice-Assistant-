import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'Provider/api_OutPut.dart';
import 'Provider/MessageModel.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Assistant(),
    );
  }
}

class Assistant extends StatefulWidget {
  const Assistant({super.key});

  @override
  State<Assistant> createState() => _AssistantState();
}

var inputText = TextEditingController();

class _AssistantState extends State<Assistant> {
  final SpeechToText speechToTextInstance = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  String recordedText = "";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeSpeechToText();
    initializeTextToSpeech();
  }

  initializeSpeechToText() async {
    await speechToTextInstance.initialize();
  }

  initializeTextToSpeech() {
    flutterTts.setLanguage('en-US');
    flutterTts.setPitch(1.0);
    flutterTts.setSpeechRate(0.5);
    flutterTts.setVolume(1.0);
  }

  startListeningNow() async {
    FocusScope.of(context).unfocus();
    await speechToTextInstance.listen(onResult: onSpeechToTextResult);
    setState(() {
      isLoading = true;
    });
  }

  void stopListeningNow() async {
    await speechToTextInstance.stop();
    setState(() {
      isLoading = false;
    });
  }

  void onSpeechToTextResult(SpeechRecognitionResult recognitionResult) {
    setState(() {
      recordedText = recognitionResult.recognizedWords;
      print(recordedText);
    });

    if (recognitionResult.finalResult) {
      // Automatically send the message when recognition is complete
      Provider.of<ChatProvider>(context, listen: false).sendMsg(prompt: recordedText);
      recordedText = ""; // Clear recorded text after sending
    }
  }

  // Define the speak method
  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xfffed6e3),
                Color(0xffa8edea),
              ],
            ),
          ),
        ),
        title: const Text("🦉 Just Ask "),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: InkWell(
              onTap: () {},
              child: const Icon(
                Icons.chat,
                size: 40,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 4),
            child: InkWell(
              onTap: () {},
              child: const Icon(
                Icons.image,
                size: 40,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 180,
                child: InkWell(
                  onTap: () async {
                    speechToTextInstance.isListening
                        ? stopListeningNow()
                        : startListeningNow();
                  },
                  child: speechToTextInstance.isListening
                      ? Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: speechToTextInstance.isListening
                            ? Colors.cyan
                            : isLoading
                            ? Colors.lightBlue
                            : Colors.blueAccent,
                        size: 300,
                      ),
                    ),
                  )
                      : Image.asset(
                    "assets/images/mic.jpg",
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: inputText,
                      decoration: const InputDecoration(
                        hintText: 'How can I help you?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      chatProvider.sendMsg(prompt: inputText.text);
                      inputText.clear();
                    },
                    child: const Icon(Icons.send, size: 30),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
                color: Colors.lightBlueAccent,
              ),
              height: 450, // Added height to make ListView.builder scrollable
              child: ListView.builder(
                reverse: true,
                itemBuilder: (context, index) {
                  final message = chatProvider.listMsgs[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: message.senderId == 0
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: message.senderId == 0
                              ? Colors.blue[200]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(message.msg),
                      ),
                    ),
                  );
                },
                itemCount: chatProvider.listMsgs.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (chatProvider.listMsgs.isNotEmpty) {
            final lastAIMessage = chatProvider.listMsgs.lastWhere(
                  (msg) => msg.senderId == 1,
              orElse: () => MessageModel(msg: '', senderId: -1), // Default empty message
            );
            if (lastAIMessage.senderId == 1) {
              print("Last AI message: ${lastAIMessage.msg}"); // Debug print
              await speak(lastAIMessage.msg);
            } else {
              print("No AI message found."); // Debug print
            }
          } else {
            print("Message list is empty."); // Debug print
          }
        },
        child: Image.asset('assets/images/speaker.png'),
      ),
    );
  }
}
