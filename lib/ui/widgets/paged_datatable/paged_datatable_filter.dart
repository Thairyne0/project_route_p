part of 'paged_datatable.dart';

abstract class TableFilter<TValue> {
  final String title;
  final String id;
  final String Function(TValue value) chipFormatter;
  final TValue? defaultValue;
  final bool visible;
  final bool isMainFilter;

  const TableFilter({
    required this.id,
    required this.title,
    required this.chipFormatter,
    required this.defaultValue,
    required this.visible,
    required this.isMainFilter,
  });

  Widget buildPicker(BuildContext context, TableFilterState state);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => other is TableFilter ? other.id == id : false;
}

/// A filter that is not visible in the popup dialog but can be set with the controller.
class ProgrammaticTableFilter<TValue> extends TableFilter<TValue> {
  const ProgrammaticTableFilter({
    required super.chipFormatter,
    required super.id,
    required super.title,
    super.defaultValue,
    super.visible = false,
    required super.isMainFilter,
  });

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return const SizedBox.shrink();
  }
}

class TextTableFilter extends TableFilter<String> {
  InputDecoration? decoration;
  Function(String)? onChange;
  TextEditingController? _controller;

  TextTableFilter({
    this.onChange,
    this.decoration,
    required super.chipFormatter,
    required super.id,
    required super.title,
    super.isMainFilter = false,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    _controller ??= TextEditingController(text: state.value);

    return CLTextField(
      fillColor: CLTheme.of(context).secondaryBackground,
      controller: _controller!,
      labelText: isMainFilter ? "Cerca per $title" : "Filtra per $title",
      prefixIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedSearch01,
        color: CLTheme.of(context).secondaryText,
        size: Sizes.medium,
      ),
      prefixIconConstraints: BoxConstraints(
        minWidth: Sizes.medium + 16,
        minHeight: Sizes.medium + 16,
      ),
      onChanged:
          onChange != null
              ? (value) async {
                  onChange!(value);
                }
              : (value) async {
                  if (value.isNotEmpty) {
                    state.value = value;
                  }
                },
    );
  }
}

class DropdownTableFilter<TValue> extends TableFilter<TValue> {
  final InputDecoration? decoration;
  final List<DropdownMenuItem<TValue>> items;

  const DropdownTableFilter({
    this.decoration,
    required this.items,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return DropdownButtonFormField<TValue>(
      items: items,
      value: state.value,
      onChanged: (newValue) {},
      onSaved: (newValue) {
        state.value = newValue;
      },
      decoration: decoration ?? InputDecoration(labelText: title),
    );
  }
}

class DatePickerTableFilter extends TableFilter<DateTime> {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateFormat? dateFormat;

  const DatePickerTableFilter({
    this.decoration,
    this.dateFormat,
    required this.firstDate,
    required this.lastDate,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return _DateTimePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialDate: state.value,
      decoration: decoration ?? InputDecoration(labelText: title),
      onSaved: (newValue) {
        if (newValue != null) {
          state.value = newValue;
        }
      },
    );
  }
}

class DateRangePickerTableFilter extends TableFilter<DateTimeRange> {
  final InputDecoration? decoration;
  final DateTime firstDate, lastDate;
  final DateFormat? dateFormat;

  const DateRangePickerTableFilter({
    this.decoration,
    this.dateFormat,
    required this.firstDate,
    required this.lastDate,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return _DateTimeRangePicker(
      firstDate: firstDate,
      lastDate: lastDate,
      dateFormat: dateFormat,
      initialValue: state.value,
      decoration: decoration ?? InputDecoration(labelText: title),
      onSaved: (newValue) {
        if (newValue != null) {
          state.value = newValue;
        }
      },
    );
  }
}

/// Filtro dropdown che usa CLDropdown con supporto per ricerca sincrona
///
/// Esempio di utilizzo:
/// ```dart
/// CLDropdownTableFilterSync<MyModel>(
///   id: "myModelId",
///   title: "Seleziona modello",
///   items: myModelList,
///   itemBuilder: (context, item) => Text(item.name),
///   valueToShow: (item) => item.name,
///   valueToSend: (item) => item.id,  // Valore da inviare al backend
///   searchCallback: (query) async => myModelList.where((m) => m.name.contains(query)).toList(),
///   chipFormatter: (item) => item.name,
///   isMainFilter: false,
/// )
/// ```
class CLDropdownTableFilterSync<TValue extends Object> extends TableFilter<TValue> {
  final List<TValue> items;
  final Widget Function(BuildContext, TValue) itemBuilder;
  final String Function(TValue) valueToShow;
  final Future<List<TValue>> Function(String)? searchCallback;
  final dynamic Function(TValue)? valueToSend;

  const CLDropdownTableFilterSync({
    required this.items,
    required this.itemBuilder,
    required this.valueToShow,
    this.searchCallback,
    this.valueToSend,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return CLDropdown<TValue>.singleSync(
      hint: title,
      items: items,
      valueToShow: valueToShow,
      searchCallback: searchCallback,
      itemBuilder: itemBuilder,
      selectedValues: state.value is TValue ? state.value : null,
      onSelectItem: (newValue) {
        // Salva sempre l'oggetto completo nello stato
        state.value = newValue;
      },
    );
  }

  // Metodo per estrarre il valore da inviare al backend
  dynamic getValueForBackend(dynamic value) {
    if (value == null) return null;
    if (valueToSend != null && value is TValue) {
      return valueToSend!(value);
    }
    return value;
  }
}

/// Filtro dropdown che usa CLDropdown con supporto per ricerca asincrona
///
/// Esempio di utilizzo:
/// ```dart
/// CLDropdownTableFilterAsync<City>(
///   id: "cityId",
///   title: "Seleziona città",
///   searchCallback: viewModel.getAllCities,
///   searchColumn: "name",
///   itemBuilder: (context, city) => Text(city.name),
///   valueToShow: (city) => city.name,
///   valueToSend: (city) => city.id,  // Valore da inviare al backend
///   chipFormatter: (city) => city.name,
///   isMainFilter: false,
/// )
/// ```
class CLDropdownTableFilterAsync<TValue extends Object> extends TableFilter<TValue> {
  final Future<(List<TValue>, Object?)> Function({int? page, int? perPage, Map<String, dynamic>? searchBy, Map<String, dynamic>? orderBy})
      searchCallback;
  final String searchColumn;
  final Widget Function(BuildContext, TValue) itemBuilder;
  final String Function(TValue) valueToShow;
  final dynamic Function(TValue)? valueToSend;

  const CLDropdownTableFilterAsync({
    required this.searchCallback,
    required this.searchColumn,
    required this.itemBuilder,
    required this.valueToShow,
    this.valueToSend,
    required super.chipFormatter,
    required super.id,
    required super.title,
    required super.isMainFilter,
    super.defaultValue,
  }) : super(visible: true);

  @override
  Widget buildPicker(BuildContext context, TableFilterState state) {
    return CLDropdown<TValue>.singleAsync(
      hint: title,
      searchCallback: searchCallback,
      searchColumn: searchColumn,
      valueToShow: valueToShow,
      itemBuilder: itemBuilder,
      selectedValues: state.value is TValue ? state.value : null,
      onSelectItem: (newValue) {
        // Salva sempre l'oggetto completo nello stato
        state.value = newValue;
      },
    );
  }

  // Metodo per estrarre il valore da inviare al backend
  dynamic getValueForBackend(dynamic value) {
    if (value == null) return null;
    if (valueToSend != null && value is TValue) {
      return valueToSend!(value);
    }
    return value;
  }
}

