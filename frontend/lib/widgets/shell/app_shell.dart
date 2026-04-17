import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import 'left_sidebar.dart';
import 'right_sidebar.dart';
import 'weaver_tab_bar.dart';
import '../chat/chat_view.dart';
import '../dashboard/dashboard_view.dart';
import '../../screens/workflows_screen.dart';
import '../../screens/settings_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WeaverColors.background,
      body: Row(
        children: [
          const LeftSidebar(),
          Expanded(
            child: Column(
              children: [
                const WeaverTabBar(),
                Expanded(
                  child: Consumer<AppState>(
                    builder: (context, appState, _) {
                      return IndexedStack(
                        index: appState.navIndex,
                        children: const [
                          ChatView(),
                          DashboardView(),
                          WorkflowsScreen(),
                          SettingsScreen(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const RightSidebar(),
        ],
      ),
    );
  }
}
