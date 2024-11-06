import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';


class connectionController extends GetxController{
  late StreamController<bool> deviceBluetoothController;
  StreamSubscription<DiscoveredDevice>? scanSub;
  StreamSubscription<ConnectionStateUpdate>? connectSub;
  StreamSubscription<List<int>>? _notifySub;
  List<DiscoveredDevice> foundDevices = [];
  bool isBluetoothOn = false;
  bool gifLoaded = false;
  String ConnectedId = "";
  bool RX_found = false;
  late StreamController<bool> RxfoundController;
  late List<DiscoveredService> discoveredServices;
  late Uuid characteristicId;

  String connectionStatus= '';
  bool bluetoth_connected = false;
  final FlutterReactiveBle ble = FlutterReactiveBle();
  //final Connectivity _connectivity = Connectivity();


  void isEnableBluetooth() {
    print("fun start");
    ble.statusStream.listen((status) {
      if(status == BleStatus.ready){
        isBluetoothOn = true;
        print("on");
      }else{
        isBluetoothOn = false;
        print("off");
      }
      // isBluetoothOn = status == BleStatus.ready;
      // deviceBluetoothController.sink.add(isBluetoothOn);
      update();

    });

  }

  void startScan() {
    print("Start scan");
    connectSub?.cancel();
    scanSub?.cancel();
    update();
    foundDevices = [];
    update();
    // Cancel any previous scan
    // connectSub?.cancel();
    scanSub = ble.scanForDevices(withServices: []).listen(
          (device) {
        if (!foundDevices.any((d) => d.id == device.id) &&
            device.name.isNotEmpty) {
          foundDevices.add(device);
          update();
          print("device: $device");
          print("device array: ${foundDevices.first}");
        }
      },
      onError: (error) {
        if (error is GenericFailure<ScanFailure>) {
          // Handle the scan failure and retry if necessary
          print("Scan failed with code: ${error.code}, message: ${error
              .message}");
          if (error.code == ScanFailure.unknown) {
            DateTime retryDate = DateTime.parse(
                error.message!.split("date is ")[1]);
            Duration retryDuration = retryDate.difference(DateTime.now());
            Timer(retryDuration, startScan);
          }
        }
      },
    );
    update();
  }

  void connectToDevice(String foundDeviceId,DiscoveredDevice device) {
    //scanSub?.cancel();
    connectSub?.cancel();
    update();
    connectSub = ble.connectToDevice(
      id: foundDeviceId,
      //servicesWithCharacteristicsToDiscover: {serviceId: [char1, char2]},
      connectionTimeout: const Duration(seconds: 2),
    ).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print("connected");
        Uuid service = device.serviceUuids.first;
        ConnectedId = foundDeviceId;
        print(ConnectedId);
        update();
        RX_found = true;
        update();
        RxfoundController.sink.add(RX_found);
        update();
      } else if (connectionState.connectionState ==
          DeviceConnectionState.disconnected) {
        print("disconnected");
        ConnectedId = "";
        update();
        RX_found = false;
        update();
        RxfoundController.sink.add(RX_found);
        update();
        //ConnectedId = foundDeviceId;
        connectToDevice(foundDeviceId,device);
      } else {
        print(connectionState.toString());
      }

      // Handle connection state updates
    }, onError: (Object error) {
      // Handle a possible error
    });
  }


  void disconnect() {
    connectSub?.cancel();
    scanSub?.cancel();
    RX_found = false;
    RxfoundController.sink.add(RX_found);
    ConnectedId = "";
    update();

  }

}