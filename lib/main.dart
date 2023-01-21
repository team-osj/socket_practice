import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_practice/baseurl.dart';
import 'dart:async';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSocket streamSocket = StreamSocket();

  IO.Socket socket = IO.io(
      '$url/application',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build());

  _connect() {
    socket.onConnect((data) => debugPrint('연결 성공'));
    socket.on('update', (data) {
      debugPrint('받은 값 : $data');
      return streamSocket.addResponse;
    });
    socket.onDisconnect((data) => debugPrint('끊김'));
    socket.connect();
  }

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: streamSocket.getResponse,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Center(child: Text(snapshot.data.toString()));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("에러"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}
