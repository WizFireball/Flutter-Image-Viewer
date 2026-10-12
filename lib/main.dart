import 'package:flutter/material.dart';
import 'package:image_app1/image_viewer.dart';
import 'package:image_app1/settings/app_settings.dart';
import 'package:window_manager/window_manager.dart';

// [NEED TO ADD/FIX] 
//
// 1. A light Theme UI [ Damn i hard coded the black theme ]
// 2. Something to scale according to screen size or manual scale

const _bg = Color(0xFF111111);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await appSettings.load();

  const windowOptions = WindowOptions(
    size: Size(960, 640),
    minimumSize: Size(480, 360),
    center: true,
    backgroundColor: _bg,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Viewer',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C9CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _bg,
      ),
      // Only the tooltips rebuild when the tooltip size changes,
      // not the whole app.
      builder: (context, child) => ValueListenableBuilder<double>(
        valueListenable: appSettings.tooltipSize,
        child: child,
        builder: (context, size, child) => TooltipTheme(
          data: TooltipThemeData(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(6),
            ),
            textStyle: TextStyle(color: Colors.white, fontSize: size),
            waitDuration: const Duration(milliseconds: 500),
          ),
          child: child!,
        ),
      ),
      home: const ImageViewer(),
    );
  }
}
