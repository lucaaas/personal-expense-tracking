import 'package:flutter/cupertino.dart';

class GraphBarWidget extends StatelessWidget {
  final double percentage;
  final Color color;
  final String? value;
  final String? title;
  final CrossAxisAlignment crossAxisAlignment;

  const GraphBarWidget({
    super.key,
    required this.percentage,
    required this.color,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.value,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (title != null) Text(title!),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                stops: [0.0, percentage, percentage, 1],
                colors: [
                  color,
                  color,
                  CupertinoColors.transparent,
                  CupertinoColors.transparent,
                ],
              ),
            ),
            width: constraints.maxWidth,
            height: 20,
            child: value != null
                ? Text(
                    value!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.black,
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}
