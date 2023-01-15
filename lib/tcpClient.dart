import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TCPClient {
  late Socket socket;

  connect(String ip, int port) async {
    Socket.connect(ip, port).then((Socket sock) {
      socket = sock;
      socket.listen(dataHandler,
          onError: errorHandler);
    }).catchError((e) {
      print("Unable to connect: $e");
    });
  }

  send(String value) {
    socket.add(utf8.encode(value));
  }

  void dataHandler(data){
    print(String.fromCharCodes(data).trim());
  }

  void errorHandler(error, StackTrace trace){
    print(error);
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