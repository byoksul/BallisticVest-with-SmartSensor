import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:mm_app/connection.dart';

import 'package:mm_app/communicationPage.dart';
import 'package:mm_app/numaraGuncelle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kevlar Yelek',
      theme: ThemeData(
        primaryColor: Colors.green.shade900,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: FlutterBluetoothSerial.instance.requestEnable(),
        builder: (context, future) {
          if (future.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
                height: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.bluetooth_disabled,
                    size: 200.0,
                    color: Colors.blue,
                  ),
                ),
              ),
            );
          } else if (future.connectionState == ConnectionState.done) {
            // return MyHomePage(title: 'Flutter Demo Home Page');
            return Home();
          } else {
            return Home();
          }
        },
      ),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var WColor;
    return Container(
        child: Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green.shade900,
              ),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://cdn.freelogovectors.net/wp-content/uploads/2020/12/turk_silahli_kuvvetleri_logo.png"),
                      radius: 60.0,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Türk Silahlı Kuvvetleri",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text("Telefon Numarasını Güncelle"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NumaraGuncelle()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Bağlantı Sayfası'),
      ),
      body: SelectBondedDevicePage(
        onChatPage: (device1) {
          BluetoothDevice device = device1;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ChatPage(server: device);
              },
            ),
          );
        },
      ),
    ));
  }
}
