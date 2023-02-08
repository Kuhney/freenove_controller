import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/services.dart';

import 'helpers.dart';
import 'globals.dart' as globals;

const color = Colors.lightGreen;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]).then((_){
    runApp(const MaterialApp(
      title: 'Connect to Robot',
      home: ConnectRoute(),
    ));
  });

}

class ControlRoute extends StatelessWidget {
  const ControlRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(globals.ipAddress),
        centerTitle: true,
        toolbarHeight: 40,
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        color: color,
                        child: InkWell(
                          splashColor: color.withAlpha(30),
                          onTapDown: (details) {
                            debugPrint('Buzzer on');
                            globals.tcpClient.send(">Buzzer Alarm 1");
                          },
                          onTapUp: (details) {
                            debugPrint('Buzzer off');
                            globals.tcpClient.send(">Buzzer Alarm");
                          },
                          child: const SizedBox(
                            height: 30,
                            child: Center(child: Text("Buzzer", style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Joystick(
                        stick: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                spreadRadius: 2,
                                blurRadius: 2,
                              )
                            ],
                          ),
                        ),
                        mode:  JoystickMode.all,
                        listener: (details) {
                          // print(details.x);
                          // print(details.y);
                          globals.cameraHAngle = globals.cameraHAngle - details.y*5;
                          globals.cameraHAngle =  constrain(globals.cameraHAngle, 30, 180);
                          globals.tcpClient.send(">Camera Down ${globals.cameraHAngle.toInt()}");
                          globals.cameraVAngle = globals.cameraVAngle - details.x*5;
                          globals.cameraVAngle =  constrain(globals.cameraVAngle, 0, 180);
                          globals.tcpClient.send(">Camera Left ${globals.cameraVAngle.toInt()}");
                        },
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(
            flex: 3,
            child: Mjpeg(
                isLive: true,
                error: (context, error, stack) {
                  print(error);
                  print(stack);
                  return Center(child: Text(error.toString(), style: const TextStyle(color: Colors.red)));
                },
                stream: ('http://${globals.ipAddress}:8080/stream'),
              ),
          ),
          Expanded(
            flex: 2,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.red,
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTapDown: (details) {
                                debugPrint('Toggled Red Led');
                                globals.tcpClient.send(">RGB Red");
                              },
                              child: const SizedBox(
                                height: 30,
                                width: 100,
                                child: Center(child: Text("Red", style: TextStyle(color: Colors.white))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Colors.green,
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTapDown: (details) {
                                debugPrint('Toggled Green Led');
                                globals.tcpClient.send(">RGB Green");
                              },
                              child: const SizedBox(
                                height: 30,
                                width: 100,
                                child: Center(child: Text("Green", style: TextStyle(color: Colors.white))),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Card(
                            color: Colors.blue,
                            child: InkWell(
                              splashColor: Colors.blue.withAlpha(30),
                              onTapDown: (details) {
                                debugPrint('Toggled Blue Led');
                                globals.tcpClient.send(">RGB Blue");
                              },
                              child: const SizedBox(
                                height: 30,
                                width: 100,
                                child: Center(child: Text("Blue", style: TextStyle(color: Colors.white))),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    child: Joystick(
                      stick: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black,
                              spreadRadius: 2,
                              blurRadius: 2,
                              // offset: Offset(0, 3),
                            )
                          ],
                        ),
                      ),
                      mode:  JoystickMode.all,
                      listener: (details) {
                        // print(details.x);
                        // print(details.y);
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
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
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
        backgroundColor: Colors.lightBlue
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
                onPressed: () async {
                  setState(() {
                    globals.ipAddress = textController.text.toString();
                  });
                  try {
                    globals.tcpClient.disconnect();
                  } catch (e, s) {
                    print(e);
                  }
                  globals.tcpClient.connect(globals.ipAddress, 12345);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ControlRoute()),
                  );
                },
                child: Text("connect"),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    globals.tcpClient.disconnect();
                    print('Client disconnected');
                  } catch (e, s) {
                    print(e);
                    print("Client wasn't connected yet");
                  }
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
