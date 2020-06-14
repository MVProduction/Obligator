import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ObligatorApp());
}

class ObligatorApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Облигатор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _bonds = List<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    dio
        .get(
            'http://localhost:8090/bonds/fetch?fields=fullname,isin,price,couponPercent')
        .then((response) {
      final bondsData = response.data["bonds"];
      _bonds.clear();
      for (var bondData in bondsData) {
        _bonds.add(bondData);
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          height: 600,
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(columns: [
                  DataColumn(label: Text("Название")),
                  DataColumn(label: Text("Isin")),
                  DataColumn(label: Text("Цена")),
                  DataColumn(label: Text("Купон %"))
                ], rows: [
                  for (var bond in _bonds)
                    DataRow(cells: [
                      DataCell(Text(bond["fullname"].toString())),
                      DataCell(SelectableText(bond["isin"].toString())),
                      DataCell(Text(bond["price"].toString())),
                      DataCell(Text(bond["couponPercent"].toString())),
                    ])
                ]))));
  }
}
