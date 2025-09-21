import 'package:flutter/material.dart';
import 'pages/activities_page.dart';
import 'pages/budget_page.dart';
import 'pages/weather_page.dart';
import 'pages/summary_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyTrip',
      // RTL לכל האפליקציה
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({super.key});
  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _index = 0;

  static const _titles = ['פעילויות', 'תקציב', 'מזג אוויר', 'סיכום'];

  static const _screens = <Widget>[
    ActivitiesPage(),
    BudgetPage(),
    WeatherPage(),
    SummaryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index]), centerTitle: true),
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'פעילויות'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'תקציב'),
          NavigationDestination(icon: Icon(Icons.cloud), label: 'מזג אוויר'),
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'סיכום'),
        ],
      ),
      floatingActionButton: _fabForTab(_index),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // כפתור + רק בטאבים הרלוונטיים (פעילויות/תקציב כרגע)
  Widget? _fabForTab(int index) {
    if (index == 0 || index == 1) {
      return FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('לחצת על + ב"${_titles[index]}"')),
          );
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
