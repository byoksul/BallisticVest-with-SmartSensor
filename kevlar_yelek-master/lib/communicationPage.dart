import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:mm_app/degisken.dart';
import 'package:mm_app/gps_service.dart';
import 'package:mm_app/validator/phone_validator_mixin.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> with PhoneValidatorMixin {
  static final clientID = 0;
  BluetoothConnection connection;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Cihaza Bağlandı');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: (isConnecting
              ? Text('Bağlantı Kuruluyor ' + widget.server.name + '...')
              : isConnected
                  ? Text('Bağlantı Kuruldu ' + widget.server.name)
                  : Text('İletişim Halinde ' + widget.server.name))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Flexible(
              child: ListView(
                  padding: const EdgeInsets.all(12.0),
                  controller: listScrollController,
                  children: list),
            ),
            Title(
              color: Colors.black,
              child: Text(
                "Ballistic Vest with Smart Sensor",
                style: new TextStyle(fontSize: 20.0),
              ),
            ),
            Image.asset("assets/images/soldier2.jpg", fit: BoxFit.cover),
            // Row(
            //   children: <Widget>[
            //     Flexible(
            //       child: new Container(
            //         padding: new EdgeInsets.only(right: 14.0),
            //         child: new Text(
            //           'Ballistic Vest with SmartSensor',
            //           overflow: TextOverflow.ellipsis,
            //         ),
            //       ),
            //     ),
            //     Container(
            //       margin: const EdgeInsets.all(8.0),
            //       child: IconButton(
            //         icon: const Icon(Icons.timer),
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);

        String mesajMetni = messages[messages.length - 1].text;
        mesajGeldiginde(mesajMetni);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  void mesajGeldiginde(String mesajMetni) {
    if (mesajMetni.contains("Mesaj gonder")) {
      aramaYap();
      mesajGonder();
    }
  }

  void mesajGonder() async {
    var pos = await GpsService().getPosition();
    String posLink =
        'https://www.google.com.tr/maps/@${pos.latitude},${pos.longitude},15z?hl=tr';
    if (await _isPermissionGranted()) {
      sendMessage(Degisken.arananNumara, "Acil Durum\nOlay Yeri\n$posLink",
          simSlot: 1);
    } else
      _getPermission();
  }

  void aramaYap() async {
    FlutterPhoneDirectCaller.callNumber(Degisken.arananNumara);
  }

  _getPermission() async => await [
        Permission.sms,
      ].request();

  Future<bool> _isPermissionGranted() async =>
      await Permission.sms.status.isGranted;

  sendMessage(String phoneNumber, String message, {int simSlot}) async {
    var result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber, message: message, simSlot: simSlot);
    if (result == SmsStatus.sent) {
      print("gönderildi");
    } else {
      print("hata");
    }
  }
}
