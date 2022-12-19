import 'dart:convert';
import 'dart:io';

class TCPClient {
  late Socket socket;

  connect(String ip, int port) async {
    socket = await Socket.connect(ip, port);
    print('connected');
  }

  send(String value) {
    socket.add(utf8.encode(value));
  }

  receive() {
    // listen to the received data event stream
    socket.listen((List<int> event) {
      print(utf8.decode(event));
    });
  }

  disconnect(){
    socket.close();
  }

}