import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
// import ‘package:flutter/services.dart’;

import 'helpers.dart';
import 'globals.dart' as globals;

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.landscapeLeft,
  //   DeviceOrientation.portraitUp
  // ]);
  runApp(const MaterialApp(
    title: 'Connect to Robot',
    home: ConnectRoute(),
  ));
}

class ControlRoute extends StatelessWidget {
  const ControlRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control your Robot'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Mjpeg(
              isLive: true,
              error: (context, error, stack) {
                print(error);
                print(stack);
                return Text(error.toString(), style: const TextStyle(color: Colors.red));
              },
              stream: ('http://${globals.ipAddress}:8080/stream'),
            ),
          ),
          ElevatedButton(onPressed: () async{
            globals.tcpClient.send(">Buzzer Alarm1");
            await Future.delayed(const Duration(seconds: 1));
            globals.tcpClient.send(">Buzzer Alarm");
          }, child: const Text("Buzzer")),
          ElevatedButton(onPressed: () async{
            globals.tcpClient.send(">Camera Down 45");
            globals.cameraHAngle = 45;
            globals.tcpClient.send(">Camera Left 90");
            globals.cameraVAngle = 90;
          }, child: const Text("Camera Reset")),
          ElevatedButton(
              onPressed: () async{
                globals.tcpClient.send(">Move Forward 35");
                await Future.delayed(const Duration(milliseconds: 500));
                globals.tcpClient.send(">Move Backward 35");
                await Future.delayed(const Duration(milliseconds: 500));
                globals.tcpClient.send(">Move Stop");
              },
              child: const Text("Move Jiggle")
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Change Connection'),
          ),
          Row(
            children: [
              Joystick(
                mode:  JoystickMode.all,
                listener: (details) {
                  print(details.x);
                  print(details.y);
                  globals.cameraHAngle = globals.cameraHAngle - details.y*5;
                  globals.cameraHAngle =  constrain(globals.cameraHAngle, 30, 180);
                  globals.tcpClient.send(">Camera Down ${globals.cameraHAngle.toInt()}");
                  globals.cameraVAngle = globals.cameraVAngle - details.x*5;
                  globals.cameraVAngle =  constrain(globals.cameraVAngle, 0, 180);
                  globals.tcpClient.send(">Camera Left ${globals.cameraVAngle.toInt()}");
                },
              ),
              Joystick(
                base: JoystickBase(mode: JoystickMode.all),
                mode:  JoystickMode.all,
                listener: (details) {
                  print(details.x);
                  print(details.y);
                  if (details.y < 0){
                    globals.speed = details.y*(-100);
                    globals.speed = constrain(globals.speed, 0, 100);
                    globals.tcpClient.send(">Move Forward ${globals.speed.toInt()}");
                  }else{
                    globals.speed = details.y*100;
                    globals.speed = constrain(globals.speed, 0, 100);
                    globals.tcpClient.send(">Move Backwards ${globals.speed.toInt()}");
                  }
                  globals.turnAngle = numMap(details.x, -1, 1, 170, 10);
                  globals.tcpClient.send(">Turn Center ${globals.turnAngle.toInt()}");
                  // globals.cameraVAngle = globals.cameraVAngle - details.x*5;
                  // globals.cameraVAngle =  constrain(globals.cameraVAngle, 0, 180);
                  // globals.tcpClient.send(">Camera Left ${globals.cameraVAngle.toInt()}");
                },
              ),
            ]
          ),
        ],
      ),
    );
  }
}


class ConnectRoute extends StatefulWidget {
  const ConnectRoute({Key? key}) : super(key: key);

  @override
  State<ConnectRoute> createState() => _ConnectRouteState();
}

class _ConnectRouteState extends State<ConnectRoute> {
  TextEditingController textController = TextEditingController(text: '192.168.178.145');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to your Robot"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // WebViewXPage(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'IP-Addresse'
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    globals.ipAddress = textController.text.toString();
                  });
                  try {
                    globals.tcpClient.disconnect();
                    print('Client disconnected');
                  } catch (e, s) {
                    print(s);
                  }
                  globals.tcpClient.connect(globals.ipAddress, 12345);
                  print('Client connected');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ControlRoute()),
                  );
                },
                child: Text("connect"),
              ),
              ElevatedButton(
                onPressed: () {
                  globals.tcpClient.disconnect();
                  print('Client disconnected');
                },
                child: Text("disconnect"),
              )
            ],
          ),
        ],
      ),
    );
  }
}
