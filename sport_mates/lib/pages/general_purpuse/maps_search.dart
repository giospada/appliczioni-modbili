import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Duration debounceDuration = Duration(milliseconds: 500);

class MapSearchBar extends StatefulWidget {
  const MapSearchBar({super.key, required this.onSearch});
  final Function(double lat, double lon) onSearch;

  @override
  State<MapSearchBar> createState() => _MapSearchBarState(onSearch: onSearch);
}

class _MapSearchBarState extends State<MapSearchBar> {
  final Function(double lat, double lon) onSearch;

  String? _currentQuery;

  List<dynamic> _lastOptions = [];

  late final _Debounceable<List<dynamic>?, String> _debouncedSearch;

  _MapSearchBarState({required this.onSearch});

  Future<List<dynamic>?> _search(text) async {
    try {
      _currentQuery = text;
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${text}&format=json&polygon_geojson=1&addressdetails=1'),
      );
      if (_currentQuery != text) {
        return null;
      }
      _currentQuery = null;
      if (response.statusCode == 200) {
        List<dynamic> suggestions = jsonDecode(response.body);
        return suggestions;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<List<dynamic>?, String>(_search);
  }

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) async {
        List<dynamic>? suggestions = (await _debouncedSearch(controller.text));

        if (suggestions == null) {
          suggestions = _lastOptions;
        } else {
          _lastOptions = suggestions.toList();
        }

        return suggestions.map((suggestion) {
          return ListTile(
            title: Text(suggestion['display_name']),
            onTap: () {
              controller.closeView(suggestion['display_name']);
              double lat = double.parse(suggestion['lat']);
              double lon = double.parse(suggestion['lon']);
              onSearch(lat, lon);
            },
          );
        }).toList();
      },
    );
  }
}

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class DebounceTimer {
  DebounceTimer(
      {Duration debounceDuration = const Duration(milliseconds: 300)}) {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
