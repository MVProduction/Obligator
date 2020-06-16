import 'dart:html';

/// Функция которая вызывается при нажатии на колонку
typedef OnColumnClickFunc = void Function();

/// Таблица отображающая данные
class DataTable {
  /// Коренной элемент
  TableElement _root;

  TableSectionElement _tbody;

  TableSectionElement _thead;

  /// Добавляет колонку
  void addColumn(String name, OnColumnClickFunc onClick) {
    final column = Element.th();
    column.text = name;
    column.style.borderBottom = '1px solid #111';
    column.onClick.listen((event) {
      onClick();
    });
    _thead.append(column);
  }

  /// Добавляет значения по колонкам
  void addRow(List<String> values) {
    final row = Element.tr();
    for (var val in values) {
      final colValue = Element.td();
      colValue.text = val;
      row.append(colValue);
    }

    _tbody.append(row);
  }

  /// Очищает все строки таблицы
  void clear() {
    _tbody.children.clear();
  }

  /// Присоединяет к DOM компоненту
  void mount(Element element) {
    _root = TableElement();
    _thead = _root.createTHead();
    _tbody = _root.createTBody();    
    element.append(_root);
  }
}
