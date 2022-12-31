import 'package:flutter/material.dart';
import 'package:freenove_controller/tcpClient.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),

  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tcpClient = TCPClient(); // "192.168.178.145", 12345

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Freenove Controller"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // WebViewXPage(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: myController,
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
                  print(myController.text);
                  tcpClient.connect(myController.text.toString(), 12345);
                },
                child: Text("connect"),
              ),
              ElevatedButton(
                onPressed: () {
                  tcpClient.disconnect();
                },
                child: Text("disconnect"),
              ),
            ],
          ),
          Mjpeg(
            isLive: true,
            error: (context, error, stack) {
              print(error);
              print(stack);
              return Text(error.toString(), style: TextStyle(color: Colors.red));
            },
            stream:
            'http://192.168.178.145:8080/stream', //'http://192.168.1.37:8081',
          ),
          ElevatedButton(onPressed: () async{
            tcpClient.send(">Buzzer Alarm1");
            await Future.delayed(const Duration(seconds: 1));
            tcpClient.send(">Buzzer Alarm");
          }, child: const Text("Buzzer")),
          ElevatedButton(onPressed: () async{
            tcpClient.send(">Camera Down 110");
            await Future.delayed(const Duration(seconds: 1));
            tcpClient.send(">Camera Up 70");
          }, child: const Text("Camera Jiggle")),
        ],
      ),
    );
  }
}
