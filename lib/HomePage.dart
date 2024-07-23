//import 'package:allen/feature_box.dart';
//import 'package:allen/openai_service.dart';
//import 'package:allen/pallete.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:chat_assistant/feature_box.dart';
import 'package:chat_assistant/open_ai_service.dart';
import 'package:chat_assistant/pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text('itu'),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning, what task can I do for you?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3 * delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
          onPressed: () async {
            if (await speechToText.hasPermission &&
                speechToText.isNotListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                generatedImageUrl = speech;
                generatedContent = null;
                setState(() {});
              } else {
                generatedImageUrl = null;
                generatedContent = speech;
                setState(() {});
                await systemSpeak(speech);
              }
              await stopListening();
            } else {
              initSpeechToText();
            }
          },
          child: Icon(
            speechToText.isListening ? Icons.stop : Icons.mic,
          ),
        ),
      ),
    );
  }
}


// import 'package:chat_assistant/feature_box.dart';
// import 'package:chat_assistant/open_ai_service.dart';
// import 'package:chat_assistant/pallete.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _lastWords = '';
//   final OpenAIService openAIService = OpenAIService();

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   /// This has to happen only once per app
//   Future<void> _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }

//   /// Each time to start a speech recognition session
//   Future<void> _startListening() async {
//     await _speechToText.listen(onResult: _onSpeechResult);
//     setState(() {});
//   }

//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   Future<void> _stopListening() async {
//     await _speechToText.stop();
//     setState(() {});
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _speechToText.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('I T U', textAlign: TextAlign.center),
//         leading: const Icon(Icons.menu),
//         centerTitle: true,
//         backgroundColor: Colors.red,
//       ),
//       body: Column(
//         children: [
//           Stack(
//             children: [
//               Center(
//                 child: Container(
//                   height: 120,
//                   width: 120,
//                   margin: const EdgeInsets.only(top: 4),
//                   decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Pallete.assistantCircleColor),
//                 ),
//               ),
//               Container(
//                   height: 123,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     image: DecorationImage(
//                       image: AssetImage("images/virtualAssistant.png"),
//                     ),
//                   )),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//             margin: const EdgeInsets.symmetric(
//               horizontal: 40,
//             ).copyWith(top: 30),
//             decoration: BoxDecoration(
//                 border: Border.all(color: Pallete.borderColor),
//                 shape: BoxShape.rectangle,
//                 borderRadius: const BorderRadius.all(Radius.circular(20))
//                     .copyWith(topLeft: Radius.zero),
//                 color: Color.fromARGB(255, 190, 130, 130)),
//             child: const Text(
//               'Good Morning Everyone!',
//               style: TextStyle(
//                 fontFamily: 'GoogleFonts.poppins',
//                 fontSize: 25,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(10),
//             alignment: Alignment.centerLeft,
//             margin: EdgeInsets.only(
//               top: 10,
//               left: 22,
//             ),
//             child: Text(
//               'Here are some Important Commands',
//               style: GoogleFonts.poppins(
//                 textStyle: const TextStyle(
//                   fontSize: 25,
//                   color: Pallete.mainFontColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const Column(
//             children: [
//               FeatureBox(
//                 color: Pallete.firstSuggestionBoxColor,
//                 headerText: "ChatGPT",
//                 descriptionText:
//                     'The smarter way to stay organized and informed with chatGPT. The smarter way to stay organized and informed with chatGPT, The smarter way to stay organized and informed with chatGPT',
//               ),
//               FeatureBox(
//                 color: Pallete.secondSuggestionBoxColor,
//                 headerText: "Dell-E",
//                 descriptionText:
//                     'The smarter way to stay organized and informed with Dell-E',
//               ),
//               FeatureBox(
//                 color: Pallete.thirdSuggestionBoxColor,
//                 headerText: "Smarter voice Assistant",
//                 descriptionText:
//                     'The smarter way to stay organized and informed with voice Assistant',
//               ),
//             ],
//           )
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Pallete.firstSuggestionBoxColor,
//         onPressed: () async {
//           if (await _speechToText.hasPermission &&
//               _speechToText.isNotListening) {
//             await _startListening();
//           } else if (_speechToText.isListening) {
//             final speech = openAIService.isArtPromptAPI(_lastWords);
//             print(speech);
//             await _stopListening();
//           } else {
//             await _initSpeech();
//           }
//         },
//         child: const Icon(Icons.mic),
//       ),
//     );
//   }
// }
