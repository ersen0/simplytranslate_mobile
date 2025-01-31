import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:clipboard_listener/clipboard_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:get_storage/get_storage.dart';
import 'package:simplytranslate_mobile/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simplytranslate_mobile/screens/about/about_screen.dart';
// import 'package:simplytranslate_mobile/screens/overlay/overlay_screen.dart';
import 'package:simplytranslate_mobile/screens/settings/settings_screen.dart';
import 'data.dart';
import 'google/google_translate_widget.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    WidgetsFlutterBinding.ensureInitialized();
  } on CameraException catch (e) {
    print(e);
  }
  ByteData data =
      await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  await GetStorage.init();

  final sessionInstances = session.read('instances');
  if (sessionInstances != null) {
    List<String> tmp = [];
    for (var item in sessionInstances) tmp.add(item.toString());
    instances = tmp;
  }

  instance = session.read('instance_mode') ?? instance;

  final sessionCustomInstance = session.read('customInstance') ?? '';
  customUrlCtrl.text = sessionCustomInstance;
  customInstance = sessionCustomInstance;

  var themeSession = session.read('theme').toString();
  if (themeSession != 'null') {
    if (themeSession == 'system') {
      themeRadio = AppTheme.system;
      theme = SchedulerBinding.instance!.window.platformBrightness;
    } else if (themeSession == 'light') {
      themeRadio = AppTheme.light;
      theme = Brightness.light;
    } else if (themeSession == 'dark') {
      themeRadio = AppTheme.dark;
      theme = Brightness.dark;
    }
  }
  flutterTesseractOcrTessdataPath = await FlutterTesseractOcr.getTessdataPath();

  two2three.forEach((key, value) {
    var dir = Directory(flutterTesseractOcrTessdataPath);

    if (!dir.existsSync()) dir.create();

    var dirList = dir.listSync();
    dirList.forEach((element) {
      String name = element.path.split('/').last;
      if (name == '$value.traineddata')
        downloadingList[key] = TrainedDataState.Downloaded;
    });
  });

  var _clipData = (await Clipboard.getData(Clipboard.kTextPlain))?.text;

  isClipboardEmpty = _clipData.toString() == '' || _clipData == null;

  packageInfo = await PackageInfo.fromPlatform();

  return runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    ClipboardListener.addListener(() async {
      var _clipData = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (_clipData.toString() == '' || _clipData == null) {
        if (!isClipboardEmpty) setState(() => isClipboardEmpty = true);
      } else if (isClipboardEmpty) setState(() => isClipboardEmpty = false);
    });
    contextOverlordData = context;
    setStateOverlord = setState;
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
    ClipboardListener.removeListener(() {});
  }

  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Future.delayed(Duration(seconds: 1));
      getSharedText();

      var _clipData = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (_clipData.toString() == '' || _clipData == null) {
        if (!isClipboardEmpty) setState(() => isClipboardEmpty = true);
      } else {
        if (isClipboardEmpty) setState(() => isClipboardEmpty = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localeListResolutionCallback: (locales, supportedLocales) {
        List supportedLocalesCountryCode = [];
        supportedLocales.forEach(
          (item) => supportedLocalesCountryCode.add(item.countryCode),
        );

        List supportedLocalesLangCode = [];
        supportedLocales.forEach(
          (item) => supportedLocalesLangCode.add(item.languageCode),
        );

        locales!;
        List localesCountryCode = [];
        locales.forEach(
          (item) => localesCountryCode.add(item.countryCode),
        );

        List localesLangCode = [];
        locales.forEach(
          (item) => localesLangCode.add(item.languageCode),
        );

        appLocale = locales[0];
        for (var i = 0; i < locales.length; i++)
          if (supportedLocalesCountryCode.contains(localesCountryCode[i]) &&
              supportedLocalesLangCode.contains(localesLangCode[i]))
            return Locale(localesLangCode[i], localesCountryCode[i]);
          else if (supportedLocalesLangCode.contains(localesLangCode[i]))
            return Locale(localesLangCode[i]);
        return Locale('en');
      },
       localizationsDelegates: [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: greenColor,
          primaryVariant: greenColor,
          secondary: greenColor,
          secondaryVariant: greenColor,
          surface: Colors.white,
          background: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: const Color(0xffa9a9a9), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: const Color(0xffa9a9a9), width: 1.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          side: BorderSide(width: 1.5, color: const Color(0xffa9a9a9)),
        )),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 10)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        toggleableActiveColor: greenColor,
        iconTheme: IconThemeData(color: greenColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          primary: greenColor,
          primaryVariant: greenColor,
          secondary: greenColor,
          secondaryVariant: greenColor,
          surface: const Color(0xff131618),
          background: const Color(0xff131618),
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.redAccent,
          onSurface: Colors.white,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff212529),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xff131618),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: Color(0xff495057), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide(color: Color(0xff495057), width: 1.5),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xff131618),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          side: BorderSide(width: 1.5, color: const Color(0xff495057)),
        )),
        toggleableActiveColor: greenColor,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed))
                  return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                else if (states.contains(MaterialState.disabled))
                  return Color(0xff495057);
                return greenColor; // Use the component's default.
              },
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      themeMode: theme == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
      title: 'SimplyTranslate Mobile',
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(0, 60),
          child: Builder(
            builder: (context) => AppBar(
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: Container(height: 2, color: greenColor),
              ),
              actions: [
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'settings',
                      child: Text(L10n.of(context).settings),
                    ),
                    PopupMenuItem<String>(
                      value: 'about',
                      child: Text(L10n.of(context).about),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'settings')
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Settings()),
                      );
                    else if (value == 'about')
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutScreen()),
                      );
                  },
                ),
              ],
              elevation: 3,
              iconTheme: IconThemeData(),
              title: const Text('SimplyTranslate Mobile'),
            ),
          ),
        ),
        body: MainPageLocalization(),
      ),
    );
  }
}

class MainPageLocalization extends StatelessWidget {
  const MainPageLocalization({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Map<String, String> themeTranslation = {
      'dark': L10n.of(context).dark,
      'light': L10n.of(context).light,
      'system': L10n.of(context).follow_system,
    };

    themeValue = themeTranslation[session.read('theme') ?? 'system']!;

    toSelLangMap = selectLanguagesMapGetter(context);
    fromSelLangMap = selectLanguagesMapGetter(context);
    fromSelLangMap['auto'] = L10n.of(context).autodetect;

    fromLangVal = session.read('from_lang') ?? 'auto';
    toLangVal = session.read('to_lang') ?? appLocale.languageCode;
    shareLangVal = session.read('share_lang') ?? appLocale.languageCode;

    return MainPage();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    getSharedText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GoogleTranslate(),
    );
  }
}
