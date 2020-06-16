import 'dart:collection';
import 'dart:html';

import 'package:dio/dio.dart';

import 'widgets/data_table/data_table.dart';

final table = DataTable();
final orders = HashSet<String>();

/// Наполняет таблицу
void populateTable() {
  final dio = Dio();

  var url =
      'http://localhost:8090/bonds/fetch?fields=fullname,isin,listLevel,price,couponPercent,couponFrequency,offerDate,endDate';
  if (orders.isNotEmpty) {
    final ordStr = orders.join(',');
    url += '&orders=$ordStr';
  }

  dio.get(url).then((response) {
    table.clear();
    final bodnArray = response.data['bonds'];
    for (var bondItem in bodnArray) {
      final name = bondItem['fullname'].toString();
      final isin = bondItem['isin'].toString();
      final listLevel = bondItem['listLevel'].toString();
      final couponPercent = bondItem['couponPercent'].toString();
      final couponFrequency = bondItem['couponFrequency'].toString();
      final price = bondItem['price'].toString();
      final offerDate = bondItem['offerDate'] ?? '';
      final endDate = bondItem['endDate'];

      table.addRow([
        name,
        isin,
        listLevel,
        couponPercent,
        couponFrequency,
        price,
        offerDate,
        endDate
      ]);
    }
  });
}

void switchOrder(String order) {
  if (orders.contains('$order|a')) {
    orders.remove('$order|a');
    orders.add('$order|d');
  } else if (orders.contains('$order|d')) {
    orders.remove('$order|d');
  } else {
    orders.add('$order|a');
  }
}

void main() {
  table.mount(querySelector('#output'));
  table.addColumn('Название', () {
    switchOrder('fullname');
    populateTable();
  });
  table.addColumn('Isin', () {
    switchOrder('isin');
    populateTable();
  });
  table.addColumn('Листинг', () {
    switchOrder('listLevel');
    populateTable();
  });
  table.addColumn('Купон %', () {
    switchOrder('couponPercent');
    populateTable();
  });
  table.addColumn('Периодичность выплаты', () {
    switchOrder('couponFrequency');
    populateTable();
  });
  table.addColumn('Цена %', () {
    switchOrder('price');
    populateTable();
  });
  table.addColumn('Дата оферты', () {
    switchOrder('offerDate');
    populateTable();
  });
  table.addColumn('Дата погашения', () {
    switchOrder('endDate');
    populateTable();
  });

  populateTable();
}
