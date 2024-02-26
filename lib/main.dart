import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lat_compass/lat_compass.dart';
import 'package:rxdart/rxdart.dart';

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
        body: NaverMap(
          onMapReady: (controller) {
            mapController = controller;
          },
          onCameraChange: (reason, animated) {
            if (reason != NCameraUpdateReason.location) stopLocationTracking();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: onLocationButtonTapped,
          child: Icon(isLocationTrackingNow
              ? Icons.location_disabled
              : Icons.my_location),
        ));
  }

  late final NaverMapController mapController;
  NLocationOverlay? locationOverlay;
  StreamSubscription<({double bearing, NLatLng latLng})>?
      locationDataStreamSubscription;
  bool isLocationTrackingNow = false;

  void onLocationChanged(({NLatLng latLng, double bearing}) data) {
    final update =
        NCameraUpdate.withParams(target: data.latLng, bearing: data.bearing)
          ..setReason(NCameraUpdateReason.location)
          ..setAnimation(
              duration: const Duration(milliseconds: 300),
              animation: NCameraAnimation.linear);

    locationOverlay
      ?..setPosition(data.latLng)
      ..setBearing(data.bearing)
      ..setIsVisible(true);
    mapController.updateCamera(update);
  }

  void onLocationButtonTapped() async {
    await initLocationPermission().onError(
        (LocationUseDenied reason, _) => handleLocationUseDenied(reason));

    if (isLocationTrackingNow) {
      stopLocationTracking();
      return;
    }

    await initLocationOverlay();
    startLocationTracking();
  }

  void startLocationTracking() {
    setState(() => isLocationTrackingNow = true);

    final positionStream = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 10))
        .map((e) => NLatLng(e.latitude, e.longitude));
    final bearingStream = LatCompass().onUpdate.map((e) => e.trueHeading);

    locationDataStreamSubscription = Rx.combineLatest2(positionStream,
            bearingStream, (le, be) => (latLng: le, bearing: be))
        .throttleTime(const Duration(milliseconds: 150))
        .listen((event) => onLocationChanged(event));
  }

  void stopLocationTracking() async {
    locationDataStreamSubscription?.resume();
    await locationDataStreamSubscription?.cancel();
    isLocationTrackingNow = false;
    setState(() {});
  }

  Future<void> initLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error(LocationUseDenied.serviceDisabled);

    final permission = await Geolocator.requestPermission();
    return switch (permission) {
      LocationPermission.denied => Future.error(LocationUseDenied.permission),
      LocationPermission.deniedForever =>
        Future.error(LocationUseDenied.permanentPermission),
      _ => Future.value()
    };
  }

  void handleLocationUseDenied(LocationUseDenied reason) {
    final deniedMessage = switch (reason) {
      LocationUseDenied.serviceDisabled => "위치 서비스를 켜주세요",
      LocationUseDenied.permission => "위치 권한을 허용해주세요",
      LocationUseDenied.permanentPermission => "설정에서 위치 권한을 허용해주세요",
    };
    print(deniedMessage);
  }

  Future<void> initLocationOverlay() async {
    locationOverlay ??= await mapController.getLocationOverlay();
    // use heading icon. iOS naver map sdk doesn't provide default heading sub icon.
    // todo : needed to provide default location sub icon from flutter_naver_map later.
    await mapController.setLocationTrackingMode(NLocationTrackingMode.follow);
    locationOverlay!.setSubIcon(null);
  }
}

enum LocationUseDenied {
  serviceDisabled,
  permission,
  permanentPermission,
}
