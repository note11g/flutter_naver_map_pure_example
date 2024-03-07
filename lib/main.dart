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
  late NaverMapController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NaverMap(
        onMapReady: (controller) => this.controller = controller,
        // forceGLSurfaceView: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMarker,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addMarker() async {
    await controller.addOverlay(
        NMarker(id: "1", position: controller.nowCameraPosition.target));
    // setState(() {});
  }
}