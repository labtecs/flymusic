import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool _queueFirst = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: SwitchListTile(
        title: Text('Lied in der Warteschlange nach oben setzen'),
        value: _queueFirst,
        onChanged: (value) {
          setState(() {
            _queueFirst = value;
          });
          Fluttertoast.showToast(msg: 'not implemented yet');
        },
      ),
    );
  }
}