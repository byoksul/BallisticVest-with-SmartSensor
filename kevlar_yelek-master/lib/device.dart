import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothDeviceListEntry extends StatelessWidget {
  final Function onTap;
  final BluetoothDevice device;

  BluetoothDeviceListEntry({this.onTap, @required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(Icons.devices),
      title: Text(device.name ?? "Bilinmeyen Cihaz"),
      subtitle: Text(device.address.toString()),
      trailing: RaisedButton.icon(
        label: Text(
          "Cihaza Bağlan",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: onTap,
        icon: Icon(Icons.bluetooth),
        color: Colors.green.shade800,
      ),
    );
  }
}
