import 'dart:collection';
import 'dart:html';

import 'package:dio/dio.dart';

import 'widgets/data_table/data_table.dart';

final table = DataTable();
final orders = HashSet<String>();
final filters = <String, String>{};

String formatDate(String dateString) {
  final date = DateTime.parse(dateString);
  final day = date.day < 10 ? '0${date.day}' : date.day;
  final month = date.month < 10 ? '0${date.month}' : date.month;
  return '${day}.${month}.${date.year}';
}

/// Наполняет таблицу
void populateTable() {
  final dio = Dio();

  var url =
      'http://localhost:8090/bonds/fetch?fields=fullname,isin,listLevel,price,couponPercent,couponFrequency,couponDate,offerDate,endDate';
  if (orders.isNotEmpty) {
    final ordStr = orders.join(',');
    url += '&orders=$ordStr';
  }

  if (filters.isNotEmpty) {
    final items = filters.entries.map((e) => '${e.key}${e.value}').join(',');
    url += '&filter=$items';
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
      final couponDate = formatDate(bondItem['couponDate']);
      final price = bondItem['price'].toString();
      final offerDate = bondItem['offerDate'] ?? '';
      final endDate = formatDate(bondItem['endDate']);

      table.addRow([
        name,
        isin,
        listLevel,
        couponPercent,
        couponFrequency,
        couponDate,
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

void applyFilter(String column, String filter) {
  if (filter.isEmpty) {
    filters.remove(column);
  } else {
    filters[column] = filter;
  }
  populateTable();
}

void main() {
  table.mount(querySelector('#output'));
  table.addColumn('Название', () {
    switchOrder('fullname');
    populateTable();
  }, (filter) {});

  table.addColumn('Isin', () {
    switchOrder('isin');
    populateTable();
  }, (filter) {});
  table.addColumn('Листинг', () {
    switchOrder('listLevel');
    populateTable();
  }, (filter) {
    applyFilter('listLevel', filter);
  });
  table.addColumn('Купон %', () {
    switchOrder('couponPercent');
    populateTable();
  }, (filter) {
    applyFilter('couponPercent', filter);
  });
  table.addColumn('Периодичность выплаты', () {
    switchOrder('couponFrequency');
    populateTable();
  }, (filter) {
    applyFilter('couponFrequency', filter);
  });
  table.addColumn('Дата купона', () {
    switchOrder('couponDate');
    populateTable();
  }, (filter) {
    applyFilter('couponDate', filter);
  });
  table.addColumn('Цена %', () {
    switchOrder('price');
    populateTable();
  }, (filter) {
    applyFilter('price', filter);
  });
  table.addColumn('Дата оферты', () {
    switchOrder('offerDate');
    populateTable();
  }, (filter) {});
  table.addColumn('Дата погашения', () {
    switchOrder('endDate');
    populateTable();
  }, (filter) {
    applyFilter('endDate', filter);
  });

  populateTable();
}
