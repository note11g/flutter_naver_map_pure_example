import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(clientId: '2vkiu8dsqb');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapExamplePage(),
    );
  }
}

class MapExamplePage extends StatefulWidget {
  const MapExamplePage({super.key});

  @override
  State<MapExamplePage> createState() => _MapExamplePageState();
}

class _MapExamplePageState extends State<MapExamplePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      const Expanded(child: NaverMap()),
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ElevatedButton(
              child: const Text("open new page"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => const IssueTestNewPage()));
              })),
    ]));
  }
}

class IssueTestNewPage extends StatelessWidget {
  const IssueTestNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Placeholder());
  }
}
