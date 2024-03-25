import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class LayoutWidget extends StatelessWidget {
  // get svg path from init
  final String? svgPath;
  final Widget? svgWidget;

  final String title;
  final String description;
  final Widget child;

  LayoutWidget(
      {required this.title,
      required this.description,
      this.child = const SizedBox(),
      this.svgPath,
      this.svgWidget}) {
    assert(svgPath != null || svgWidget != null,
        'You must provide either a svgPath or a svgWidget');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: svgWidget != null && svgPath == null
                ? svgWidget
                : SvgPicture.asset(
                    svgPath ?? '',
                    height: 100,
                    width: 100,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8), child: child),
          // make extend all width
        ],
      ),
    );
  }
}
