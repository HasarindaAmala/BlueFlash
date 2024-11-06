import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

import 'connectionScreen.dart';

void main() {
  runApp(const home());
}
class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home>  {
  

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> with TickerProviderStateMixin {

  late GifController splash;
  void checkTime() async {
    Future.delayed(const Duration(milliseconds: 7100), () {
      setState(() {
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginScreen()));
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 1000),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    connectionScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                }
            )
        );
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    splash = GifController(vsync: this);
    checkTime();
    super.initState();
  }
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Code that relies on MediaQuery or inherited widgets should go here.
    precacheImage(AssetImage("asserts/bluetooth-unscreen (1).gif"), context);
    precacheImage(AssetImage("asserts/b2d4b2c0f0ff6c95b0d6021a430beda4.gif"), context);
    precacheImage(AssetImage("asserts/spinout.gif"), context);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    splash.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Gif(
            image: AssetImage("asserts/loading.gif"),
            controller: splash,
            width: width * 0.5,
            autostart: Autostart.loop,
            onFetchCompleted: () {
              splash.reset();
              splash.forward();
            },
          ),
          Center(
            child:SizedBox(
              width: width,
                height: height,
                child: Image(image: AssetImage("asserts/splashBack.png"),fit: BoxFit.cover,)),
          ),
        ],


      ),
    );
  }
}
