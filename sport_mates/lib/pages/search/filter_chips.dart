import 'package:flutter/material.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/pages/search/filter_data.dart';

class FilterChipsWidget extends StatelessWidget {
  final FilterData filterData;
  final Function filter;
  const FilterChipsWidget(
      {super.key, required this.filterData, required this.filter});

  List<Widget> createFilterChips() {
    List<Widget> filterChips = [];

    if (filterData.price) {
      filterChips.add(Chip(
        label: Text('Prezzo Massimo ${filterData.maxPrice} €'),
        avatar: const Icon(Icons.filter),
        onDeleted: () {
          filterData.price = false;
          filterData.maxPrice = 0;
          filter(filterData);
        },
      ));
    }
    if (filterData.selectedSport != Config().nullSport) {
      filterChips.add(Chip(
        label: Text('Sport: ${filterData.selectedSport}'),
        avatar: const Icon(Icons.filter),
        onDeleted: () {
          filterData.selectedSport = Config().nullSport;
          filter(filterData);
        },
      ));
    }
    if (filterData.startDate != null) {
      filterChips.add(Chip(
        label: Text(
            'Data minima: ${filterData.startDate!.day}/${filterData.startDate!.month}'),
        avatar: const Icon(Icons.filter),
        onDeleted: () {
          filterData.startDate = null;
          filter(filterData);
        },
      ));
    }
    if (filterData.endDate != null) {
      filterChips.add(Chip(
        label: Text(
            'Data massima: ${filterData.endDate!.day}/${filterData.endDate!.month}'),
        avatar: const Icon(Icons.filter),
        onDeleted: () {
          filterData.endDate = null;
          filter(filterData);
        },
      ));
    }

    return filterChips;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8.0, // Gap between adjacent chips
        runSpacing: 4.0, // Gap between lines
        direction: Axis.horizontal, // Use horizontal Wrap for chips
        children: createFilterChips(),
      ),
    );
  }
}
