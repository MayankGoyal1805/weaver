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
        ChangeNotifierProxyProvider<BackendProvider, ToolsProvider>(
          create: (_) => ToolsProvider(),
          update: (_, backend, tools) => tools!..bindBackend(backend),
        ),
        ChangeNotifierProxyProvider2<BackendProvider, ToolsProvider, ChatProvider>(
          create: (_) => ChatProvider(),
          update: (_, backend, tools, chat) => chat!..bind(backend, tools),
        ),
        ChangeNotifierProvider(create: (_) => WorkflowsProvider()),
        ChangeNotifierProvider(create: (_) => ModelProvider()),
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
