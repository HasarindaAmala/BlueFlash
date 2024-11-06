import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'connectionController/connectionController.dart';

class connectionScreen extends StatefulWidget {
  const connectionScreen({super.key});

  @override
  State<connectionScreen> createState() => _connectionScreenState();
}

class _connectionScreenState extends State<connectionScreen>
    with TickerProviderStateMixin {
  connectionController connectionControll = Get.put(connectionController());
  late GifController blue;
  late GifController loading;
  bool _imagesLoaded = false;
  @override
  void initState() {
    // TODO: implement initState
    blue = GifController(vsync: this);
    loading = GifController(vsync: this);
    connectionControll.isEnableBluetooth();
    print(connectionControll.isBluetoothOn);
    checkPermissions();
    connectionControll.RxfoundController = StreamController<bool>.broadcast();
    super.initState();
  }
  Future<void> _preloadImages() async {
    await Future.wait([
      precacheImage(AssetImage("asserts/Ellipse 1.png"), context),
      precacheImage(AssetImage("asserts/bluetooth-unscreen (1).gif"), context),
    ]);
    setState(() {
      _imagesLoaded = true;
    });
  }
  @override

  Future<void> checkPermissions() async {
    // Request Bluetooth and location permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
      Permission.bluetoothAdvertise,
    ].request();


    // Handle the status of Bluetooth permissions
    if (statuses[Permission.bluetooth]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothAdvertise]?.isGranted == true) {
      print("All Bluetooth permissions granted");
    } else {
      print("Bluetooth permissions denied or not fully granted");
      // Optionally request them again
      await [
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
      ].request();
    }

    // At this point, all relevant permissions should be granted
    print("All necessary permissions granted");
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: width,
        height: height,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Gif(
                image: AssetImage("asserts/bluetooth-unscreen (1).gif"),
                controller: blue,
                width: width * 0.5,
                autostart: Autostart.loop,
                onFetchCompleted: () {
                  blue.reset();
                  blue.forward();
                },
              ),
              Image(
                image: AssetImage("asserts/Ellipse 1.png"),
                width: width * 0.6,
              ),
              GestureDetector(
                onTap: (){
                  showDoneDialog(width,height);
                },
                child: Container(
                  width: width*0.5,
                  height: width*0.5,
                  decoration: BoxDecoration(
                    //color: Colors.white70,
                    borderRadius: BorderRadius.circular(width*0.3),
                  ) ,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> showDoneDialog(double width, double height) async {
    connectionControll.RX_found == false ? connectionControll.startScan() : ();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
               Text('Connect to Bluetooth',style: TextStyle(fontSize: width*0.05),),
              IconButton(
                  onPressed: () {
                    connectionControll.startScan();
                  },
                  icon: Icon(Icons.restart_alt))
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GetBuilder<connectionController>(
                  builder: (controller) {
                    if (controller.foundDevices == false) {
                      return Gif(image: AssetImage("asserts/b2d4b2c0f0ff6c95b0d6021a430beda4.gif"),
                        controller: loading,
                        width: width * 0.5,
                        autostart: Autostart.loop,
                        onFetchCompleted: () {
                          loading.reset();
                          loading.forward();
                        },);
                    } else {
                      return  Container(
                          width: width * 0.2,
                          height: height * 0.2,
                          // color: Colors.red,
                          child: Image(
                            image: AssetImage("asserts/Icon-fire-clipart-transparent.png"),
                            width: width * 0.07,
                            height: width * 0.07,
                          ));
                    }
                  },
                ),





                SizedBox(
                  height: height * 0.05,
                ),
                Container(
                  width: width * 0.2,
                  height: height * 0.2,
                  color: Colors.transparent,
                  child: GetBuilder<connectionController>(
                    builder: (controller) {
                      if (controller.isBluetoothOn == false) {
                        return const Text(
                          "Turn on bluetooth..",
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 18), // Added style for visibility
                        );
                      } else {
                        return ListView.builder(
                          itemCount: controller.foundDevices.length,
                          itemBuilder: (context, index) {
                            final device = controller.foundDevices[index];
                            return Card(
                              child: ListTile(
                                title: Text(device.name.isNotEmpty
                                    ? device.name
                                    : "Unknown"),
                                subtitle: Text(device.id),
                                trailing: controller.ConnectedId == device.id
                                    ? Icon(
                                  Icons.bluetooth_connected,
                                  color: Colors.greenAccent,
                                )
                                    : Icon(
                                  Icons.bluetooth_disabled,
                                  color: Colors.black,
                                ),
                                onTap: () {
                                  // controller.ble.discoverAllServices(device.id);

                                  print('clicked ${device.name}');
                                  print(
                                      'clicked service data ${device.serviceData}');
                                  print(
                                      'clicked manufacture data ${device.manufacturerData}');
                                  print('clicked rssi data ${device.rssi}');
                                  print(
                                      'clicked serviceUUID data ${device.serviceUuids}');

                                  if (controller.RX_found == false) {
                                    controller.connectToDevice(
                                        device.id, device);
                                  } else {
                                    controller.disconnect();
                                    blue.forward();
                                    setState(() {

                                    });
                                    Navigator.of(context).pop();
                                  }


                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),

                // Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('cancel'),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pop();
                });

              },
            ),
          ],
        );
      },
    );
  }
}
