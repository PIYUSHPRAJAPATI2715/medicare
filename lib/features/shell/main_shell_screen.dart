import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/floating_bottom_nav.dart';
import '../home/home_screen.dart';
import '../in_person/in_person_screen.dart';
import '../video_consult/video_consult_tab_screen.dart';
import '../account/account_screen.dart';

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(CurrentTabNotifier.new);

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    final List<Widget> pages = const [
      HomeScreen(),
      InPersonScreen(),
      VideoConsultTabScreen(),
      AccountScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentTab,
        children: pages,
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: currentTab,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).setTab(index);
        },
      ),
    );
  }
}
