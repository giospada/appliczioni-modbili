import 'package:sport_mates/config/config.dart';

class FilterData {
  double maxPrice;
  bool price;
  String selectedSport;
  DateTime? startDate, endDate;

  FilterData(
      {required this.maxPrice,
      required this.price,
      required this.selectedSport,
      required this.startDate,
      required this.endDate});

  factory FilterData.init() => FilterData(
      maxPrice: 0,
      price: false,
      selectedSport: Config().nullSport,
      startDate: null,
      endDate: null);

  bool hasFilter() {
    var def = FilterData.init();
    return maxPrice != def.maxPrice ||
        price != def.price ||
        selectedSport != def.selectedSport ||
        startDate != def.startDate ||
        endDate != def.endDate;
  }
}
