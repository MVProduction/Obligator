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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DataTable(columns: [
              DataColumn(label: Text("Название")),
              DataColumn(label: Text("Isin")),
              DataColumn(label: Text("Цена")),
              DataColumn(label: Text("Купон %"))
            ], rows: [
              DataRow(cells: [
                DataCell(Text("Рога и копыта")),
                DataCell(Text("RU139812938")),
                DataCell(Text("1080")),
                DataCell(Text("12")),
              ]),
              DataRow(cells: [
                DataCell(Text("Говно и лопата")),
                DataCell(Text("RU98223423")),
                DataCell(Text("980")),
                DataCell(Text("9")),
              ])
            ])
          ],
        ),
      ),
    );
  }
}
