import 'package:flutter/material.dart';
import 'package:freenove_controller/tcpClient.dart';

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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: myController,
            ),
          ),
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
          ElevatedButton(onPressed: () async{
            tcpClient.send(">Buzzer Alarm1");
            await Future.delayed(Duration(seconds: 1));
            tcpClient.send(">Buzzer Alarm");
          }, child: Text("Buzzer"))
        ],
      ),
    );
  }
}
