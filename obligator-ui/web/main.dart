import 'dart:html';

import 'package:dio/dio.dart';

import 'src/data_table.dart';

void main() {
  final table = DataTable();

  final dio = Dio();
  dio
      .get(
          'http://localhost:8090/bonds/fetch?fields=fullname,isin,listLevel,price,couponPercent,couponFrequency,offerDate,endDate&orders=listLevel,couponPercent|d,price')
      .then((response) {
    table.mount(querySelector('#output'));
    table.addColumn('Название');
    table.addColumn('Isin');
    table.addColumn('Листинг');
    table.addColumn('Купон %');
    table.addColumn('Периодичность выплаты');
    table.addColumn('Цена %');
    table.addColumn('Дата оферты');
    table.addColumn('Дата погашения');

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
