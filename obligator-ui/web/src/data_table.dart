import 'dart:html';

/// Таблица отображающая данные
class DataTable {
  /// Коренной элемент
  Element _root;

  /// Добавляет колонку
  void addColumn(String name) {
    final column = Element.th();
    column.text = name;        
    column.style.borderBottom = '1px solid #111';
    _root.append(column);
  }

  /// Добавляет значения по колонкам
  void addRow(List<String> values) {
    final row = Element.tr();
    for (var val in values) {
      final colValue = Element.td();
      colValue.text = val;
      row.append(colValue);
    }

    _root.append(row);
  }

  /// Присоединяет к DOM компоненту
  void mount(Element element) {
    _root = Element.table();    
    element.append(_root);
  }
}
