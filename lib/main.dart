import 'package:chyawanprash/data/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
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
var inputText=TextEditingController();
class _AssistantState extends State<Assistant> {
  final SpeechToText speechToTextInstance = SpeechToText();
  String recordedText = "";
  bool isLoading = false;
  String resultText = ""; // Add this line to store the result from API

  initializeSpeechToText() async {
    await speechToTextInstance.initialize();
    setState(() {});
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
  }

  @override
  void initState() {
    super.initState();
    initializeSpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    // String result=output.toString();
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
                child: InkWell (
                  onTap: () async{
                    speechToTextInstance.isListening
                        ? stopListeningNow()
                        : startListeningNow();
                    // Make API call after stopping listening
                    var result = await ApiHelper().generateAiMsg(prompt: recordedText);
                    setState(() {
                      resultText = result!;
                    });
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
              padding:  const EdgeInsets.all(8.0),
              child: Row(
                children: [
                   Expanded(
                    child: TextField(
                      controller: inputText,
                      decoration: const InputDecoration(
                        hintText: 'how can i help you ?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {

                       var result= await ApiHelper().generateAiMsg(prompt: inputText.text);

                      setState(() {
                         resultText =  result!;
                      });

                      inputText.clear();
                    },
                    child: const Icon(Icons.send, size: 30),
                  ),
                ],
              ),
            ),

            Container(
              decoration: BoxDecoration(
                border:Border.all(color: Colors.lightBlueAccent),
              ),
              child:  Text(

                resultText,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Image.asset('assets/images/speaker.png'),
      ),
    );
  }
}
