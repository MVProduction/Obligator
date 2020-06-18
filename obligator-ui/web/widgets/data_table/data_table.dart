import 'dart:html';

/// Функция которая вызывается при переключении сортировки
typedef OnSortClickFunc = void Function();

/// Функция которая вызывается при изменения фильтра в колонке
typedef OnFilterChangeFunc = void Function(String filter);

/// Таблица отображающая данные
class DataTable {
  /// Коренной элемент
  TableElement _root;

  /// Элемент с заголовками
  TableSectionElement _thead;

  /// Элемент со строками
  TableSectionElement _tbody;

  /// Добавляет колонку
  void addColumn(String name, OnSortClickFunc onSort, OnFilterChangeFunc onFilter) {
    final column = Element.th();
    final inner = Element.div();
    final head = Element.div();
    head.className = 'inner';
    inner.append(head);

    final title = Element.div();
    title.className = 'title';
    title.text = name;
    final sort = Element.div();
    sort.className = 'sort';
    sort.text = '';
    head.append(title);
    head.append(sort);

    head.onClick.listen((event) {
      if (sort.text == '') {
        sort.text = 'v';
      } else if (sort.text == 'v') {
        sort.text = '^';
      } else if (sort.text == '^') {
        sort.text = '';
      }
      onSort();
    });

    final filter = InputElement();
    filter.onKeyPress.listen((event) {
      if (event.keyCode == KeyCode.ENTER) {        
        onFilter(filter.value);
      }
    });

    inner.append(filter);

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
