import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

// Multi Select widget
// This widget is reusable
class MultiSelectPopup extends StatelessWidget {
  final Filter filter;
  final String title;
  const MultiSelectPopup({Key? key, required this.filter, required this.title})
      : super(key: key);

  // this function is called when the Cancel button is pressed
  void _cancel(BuildContext context) {
    Navigator.pop(context);
  }

  // this function is called when the Submit button is tapped
  void _submit(BuildContext context) {
    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: FilterWidget(
        filter: filter,
      ),
      actions: [
        TextButton(
          onPressed: () => _cancel(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _submit(context),
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class FilterWidget extends StatefulWidget {
  final Filter filter;
  const FilterWidget({Key? key, required this.filter}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  Filter? _filter;

  @override
  void initState() {
    super.initState();
    _filter ??= widget.filter;
  }

  @override
  Widget build(BuildContext context) {
    Filter filter = _filter!;
    List<FilterType> types = filter.getFilters();
    return SingleChildScrollView(
      child: ListBody(
        children: types
            .whereNot((element) => element.hidden)
            .map(
              (type) =>
                  [Text(type.title), const Divider()].followedBy(type.items.map(
                // ignore: unnecessary_cast
                (item) => CheckboxListTile(
                  value: item.value,
                  title: Text(item.title),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (isSet) => setState(() => item.onChanged(isSet)),
                ),
              )),
            )
            .flattened
            .toList(),
      ),
    );
  }
}

abstract class Filter<E> {
  List<FilterType> getFilters();
  bool passes(E _);
  Filter<E> clone();
}

class MultipleFilter<E> implements Filter<E> {
  final List<Filter> filters;

  const MultipleFilter(this.filters);

  @override
  List<FilterType> getFilters() {
    return filters.map((e) => e.getFilters()).flattened.toList();
  }

  @override
  bool passes(E item) {
    return filters.map((e) => e.passes(item)).reduce((a, b) => a && b);
  }

  @override
  MultipleFilter<E> clone() {
    return MultipleFilter(filters.map((e) => e.clone()).toList());
  }
}

class MapFilter<K, E> implements Filter<E> {
  final String title;
  final Map<K, bool> map;
  final String Function(K) asString;
  final K Function(E) toKey;
  final bool disabled;

  const MapFilter(
      {required this.map,
      required this.title,
      required this.asString,
      required this.toKey,
      this.disabled = false});

  @override
  List<FilterType> getFilters() {
    return [
      FilterType(
        title: title,
        items: map.keys
            .map((item) => FilterItem(
                title: asString(item),
                value: map[item]!,
                onChanged: (isChecked) => map[item] = isChecked!))
            .toList(),
        hidden: disabled,
      ),
    ];
  }

  @override
  bool passes(E item) {
    return map[toKey(item)] ?? false;
  }

  @override
  MapFilter<K, E> clone() {
    return MapFilter(
      map: Map.from(map),
      title: title,
      asString: asString,
      toKey: toKey,
      disabled: disabled,
    );
  }
}

class FilterItem {
  final String title;
  final bool value;
  final Function(bool?) onChanged;

  const FilterItem(
      {required this.title, required this.value, required this.onChanged});
}

class FilterType {
  final bool hidden;
  final String title;
  final List<FilterItem> items;
  const FilterType(
      {required this.items, required this.title, this.hidden = false});
}
