import 'dart:html';

/// Функция которая вызывается при нажатии на колонку
typedef OnColumnClickFunc = void Function();

/// Таблица отображающая данные
class DataTable {
  /// Коренной элемент
  TableElement _root;

  /// Элемент с заголовками
  TableSectionElement _thead;

  /// Элемент со строками
  TableSectionElement _tbody;

  /// Добавляет колонку
  void addColumn(String name, OnColumnClickFunc onClick) {
    final column = Element.th();
    final inner = Element.div();
    inner.className = 'inner';

    final title = Element.div();
    title.className = 'title';
    title.text = name;
    final sort = Element.div();
    sort.className = 'sort';
    sort.text = '';
    inner.append(title);
    inner.append(sort);
    column.onClick.listen((event) {
      if (sort.text == '') {
        sort.text = 'v';
      } else if (sort.text == 'v') {
        sort.text = '^';
      } else if (sort.text == '^') {
        sort.text = '';
      }
      onClick();
    });

    column.append(inner);
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
    _root.className = 'data-table';
    _thead = _root.createTHead();
    _tbody = _root.createTBody();
    element.append(_root);
  }
}
