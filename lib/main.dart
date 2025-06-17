import 'package:flutter/material.dart';
import 'package:TagGlowFlutter/components/layouts/basic_layout.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:jh_debug/jh_debug.dart' show DebugMode, jhDebug, jhDebugMain;
import 'routes/generate_route.dart' show generateRoute;
import 'routes/routes_data.dart';
import 'providers_config.dart' show providersConfig;
import 'provider/theme_store.p.dart';
import 'config/common_config.dart' show commonConfig;
import 'package:ana_page_loop/ana_page_loop.dart' show anaAllObs;
import 'utils/app_setup/index.dart' show appSetupInit;

void main() {
  jhDebugMain(
    appChild: MultiProvider(
      providers: providersConfig,
      child: const MyApp(),
    ),
    debugMode: DebugMode.inConsole,
    errorCallback: (details) {},
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    jhDebug.setGlobalKey = commonConfig.getGlobalKey;
    appSetupInit();
    WidgetsFlutterBinding.ensureInitialized();

    return Consumer<ThemeStore>(
      builder: (context, themeStore, child) {
        return BasicLayout(
          child: MaterialApp(
            navigatorKey: jhDebug.getNavigatorKey,
            showPerformanceOverlay: false,

            // 1. 区域改成 zh-CN 而不是 zh-CH（CH 是瑞士拼写）
            locale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],

            initialRoute: initialRoute,
            onGenerateRoute: generateRoute,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [...anaAllObs()],
          )

        );
      },
    );
  }
}