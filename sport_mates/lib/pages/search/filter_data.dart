import 'package:latlong2/latlong.dart';
import 'package:sport_mates/config/config.dart';
import 'package:sport_mates/data/activity.dart';
import 'package:sport_mates/utils.dart';

class FilterData {
  double maxPrice;
  bool price;
  String selectedSport;
  DateTime? startDate, endDate;
  String? search;

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

  bool isValidActivity(Activity activity, LatLng? pos, double radius) {
    if (activity.numberOfPeople - activity.participants.length <= 0)
      return false;
    if (price && activity.attributes.price > maxPrice) return false;
    if (pos != null && isInRatio(activity.position, pos, radius)) return false;
    if (selectedSport != Config().nullSport &&
        activity.attributes.sport != selectedSport) return false;
    if (DateTime.now().isAfter(activity.time)) return false;
    if (startDate != null && startDate!.isAfter(activity.time)) return false;
    if (endDate != null && endDate!.isBefore(activity.time)) return false;
    return true;
  }
}
