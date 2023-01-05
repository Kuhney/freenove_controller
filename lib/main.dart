import 'package:flutter/material.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'globals.dart' as globals;

void main() {
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
          Mjpeg(
            isLive: true,
            error: (context, error, stack) {
              print(error);
              print(stack);
              return Text(error.toString(), style: const TextStyle(color: Colors.red));
            },
            stream: ('http://${globals.ipAddress}:8080/stream'),
          ),
          ElevatedButton(onPressed: () async{
            globals.tcpClient.send(">Buzzer Alarm1");
            await Future.delayed(const Duration(seconds: 1));
            globals.tcpClient.send(">Buzzer Alarm");
          }, child: const Text("Buzzer")),
          ElevatedButton(onPressed: () async{
            globals.tcpClient.send(">Camera Down 110");
            await Future.delayed(const Duration(seconds: 1));
            globals.tcpClient.send(">Camera Up 70");
          }, child: const Text("Camera Jiggle")),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Change Connection'),
            ),
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
            ],
          ),
        ],
      ),
    );
  }
}
