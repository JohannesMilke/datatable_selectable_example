import 'package:datatable_selectable_example/model/country.dart';
import 'package:datatable_selectable_example/utils.dart';
import 'package:datatable_selectable_example/widget/flag_widget.dart';
import 'package:datatable_selectable_example/widget/scrollable_widget.dart';
import 'package:flutter/material.dart';

class SelectablePage extends StatefulWidget {
  @override
  _SelectablePageState createState() => _SelectablePageState();
}

class _SelectablePageState extends State<SelectablePage> {
  List<Country> countries = [];
  List<Country> selectedCountries = [];

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    final countries = await Utils.loadCountries();

    setState(() => this.countries = countries);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: countries.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(child: ScrollableWidget(child: buildDataTable())),
                  buildSubmit(),
                ],
              ),
      );

  Widget buildDataTable() {
    final columns = ['Flag', 'Name', 'Native Name'];

    return DataTable(
      onSelectAll: (isSelectedAll) {
        setState(() => selectedCountries = isSelectedAll! ? countries : []);

        Utils.showSnackBar(context, 'All Selected: $isSelectedAll');
      },
      columns: getColumns(columns),
      rows: getRows(countries),
    );
  }

  List<DataColumn> getColumns(List<String> columns) => columns
      .map((String column) => DataColumn(
            label: Text(column),
          ))
      .toList();

  List<DataRow> getRows(List<Country> countries) => countries
      .map((Country country) => DataRow(
            selected: selectedCountries.contains(country),
            onSelectChanged: (isSelected) => setState(() {
              final isAdding = isSelected != null && isSelected;

              isAdding
                  ? selectedCountries.add(country)
                  : selectedCountries.remove(country);
            }),
            cells: [
              DataCell(FlagWidget(code: country.code)),
              DataCell(Container(
                width: 100,
                child: Text(country.name),
              )),
              DataCell(Container(
                width: 100,
                child: Text(country.nativeName),
              )),
            ],
          ))
      .toList();

  Widget buildSubmit() => Container(
        width: double.infinity,
        padding: EdgeInsets.all(12),
        color: Colors.black,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            minimumSize: Size.fromHeight(40),
          ),
          child: Text('Select ${selectedCountries.length} Countries'),
          onPressed: () {
            final names =
                selectedCountries.map((country) => country.name).join(', ');

            Utils.showSnackBar(context, 'Selected countries: $names');
          },
        ),
      );
}
