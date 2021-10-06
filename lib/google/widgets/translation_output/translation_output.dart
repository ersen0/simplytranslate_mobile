import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '/data.dart';
import '/google/screens/maximized/maximized.dart';
import '/google/widgets/translation_input/widgets/copy_button.dart';

class GoogleTranslationOutput extends StatefulWidget {
  const GoogleTranslationOutput({Key? key}) : super(key: key);

  @override
  _TranslationOutputState createState() => _TranslationOutputState();
}

class _TranslationOutputState extends State<GoogleTranslationOutput> {
  @override
  void initState() {
    super.initState();
  }

  bool isRTL = false;
  double outputFontSize = 20;

  @override
  Widget build(BuildContext context) {
    String translatedText = googleTranslationOutput;
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: theme == Brightness.dark ? Color(0xff131618) : null,
        border: Border.all(
          color:
              theme == Brightness.dark ? Color(0xff495057) : Color(0xffa9a9a9),
          width: 1.5,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Directionality(
                    textDirection:
                        intl.Bidi.detectRtlDirectionality(translatedText)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                    child: SelectableText(
                      translatedText,
                      style: TextStyle(fontSize: outputFontSize),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              CopyToClipboardButton(translatedText),
              IconButton(
                icon: Icon(Icons.fullscreen),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: translatedText == ''
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MaximizedScreen())),
              ),
              IconButton(
                icon: Icon(Icons.add),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: translatedText == ''
                    ? null
                    : () => setState(() {
                          if (outputFontSize + 3 <= 90) outputFontSize += 3;
                        }),
              ),
              IconButton(
                icon: Icon(Icons.remove),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: translatedText == ''
                    ? null
                    : () => setState(() {
                          if (outputFontSize - 3 >= 8) outputFontSize -= 3;
                        }),
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: googleTranslationOutput == ''
                    ? null
                    : () => audioPlayer.play(
                        'https://simplytranslate.org/api/tts/?engine=google&lang=$toLanguageValue&text=$googleTranslationOutput'),
                icon: Icon(Icons.volume_up),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
