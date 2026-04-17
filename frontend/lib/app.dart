import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'widgets/shell/app_shell.dart';

class WeaverApp extends StatelessWidget {
  const WeaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => BackendProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ModelProvider()..initialize()),
        ChangeNotifierProxyProvider<BackendProvider, ToolsProvider>(
          create: (_) => ToolsProvider(),
          update: (_, backend, tools) => tools!..bindBackend(backend),
        ),
        ChangeNotifierProxyProvider3<BackendProvider, ToolsProvider, ModelProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, backend, tools, model, chat) => chat!..bind(backend, tools, model),
        ),
        ChangeNotifierProvider(create: (_) => WorkflowsProvider()),
      ],
      child: MaterialApp(
        title: 'Weaver',
        debugShowCheckedModeBanner: false,
        theme: WeaverTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
