import 'package:flutter/cupertino.dart';

class BarInfo {
  final Color color;
  final double value;
  final String label;

  BarInfo({
    required this.color,
    required this.value,
    required this.label,
  }) : assert(value >= 0, "Value must be greater than or equal to 0");
}

class GraphBarWidget extends StatefulWidget {
  final List<BarInfo> bars;
  final String? prefixValue;
  final double? value;

  const GraphBarWidget({
    super.key,
    required this.bars,
    this.prefixValue = "",
    this.value,
  });

  @override
  State<GraphBarWidget> createState() => _GraphBarWidgetState();
}

class _GraphBarWidgetState extends State<GraphBarWidget> {
  String? total;
  BarInfo? selectedBar;

  @override
  initState() {
    super.initState();

    if (widget.value != null) {
      total = _concatPrefixAndValue(widget.value!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(50))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _getTotalWidget(),
              const SizedBox(height: 10),
              _GraphWidget(
                bars: widget.bars,
                maxWidth: constraints.maxWidth,
                onTap: _selectBar,
                selectedBar: selectedBar,
              ),
              const SizedBox(height: 10),
              _SubtitleWidget(bars: widget.bars, onTap: _selectBar),
            ],
          ),
        );
      },
    );
  }

  void _selectBar(BarInfo bar) {
    if (bar == selectedBar) {
      setState(() {
        selectedBar = null;
        total = _concatPrefixAndValue(widget.value!);
      });
    } else {
      setState(() {
        selectedBar = bar;
        total = _concatPrefixAndValue(bar.value);
      });
    }
  }

  String _concatPrefixAndValue(double value) {
    return "${widget.prefixValue!} ${value.toStringAsFixed(2).replaceAll(".", ",")}";
  }

  Widget _getTotalWidget() {
    if (total != null) {
      return Text(
        total!,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: selectedBar?.color),
      );
    }

    return const SizedBox();
  }
}

class _GraphWidget extends StatelessWidget {
  final List<BarInfo> bars;
  final double maxWidth;
  final void Function(BarInfo)? onTap;
  final BarInfo? selectedBar;

  const _GraphWidget({
    super.key,
    required this.bars,
    required this.maxWidth,
    this.onTap,
    this.selectedBar,
  });

  @override
  Widget build(BuildContext context) {
    double total = 0;

    for (BarInfo bar in bars) {
      double value = bar.value < 0 ? bar.value * -1 : bar.value;
      total += value;
    }

    return SizedBox(
      height: 30,
      child: Stack(
        children: List.generate(
          bars.length,
          (index) => Positioned(
            left: getPosition(index, maxWidth, total),
            bottom: 0,
            width: maxWidth * (bars[index].value) / total,
            child: SizedBox(
              height: bars[index] == selectedBar ? 30 : 20,
              width: double.infinity,
              child: GestureDetector(
                onTap: () => onTap?.call(bars[index]),
                child: Container(
                  decoration: BoxDecoration(
                    color: bars[index].color,
                  ),
                  child: const Text(''),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getPosition(int index, double maxWidth, double total) {
    double position = 0;

    if (index > 0) {
      for (int i = 0; i < index; i++) {
        position += (maxWidth * (bars[index].value) / total);
      }

      position = maxWidth - position;
    }

    return position;
  }
}

class _SubtitleWidget extends StatelessWidget {
  final List<BarInfo> bars;
  final void Function(BarInfo)? onTap;

  const _SubtitleWidget({super.key, required this.bars, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 10,
      alignment: WrapAlignment.spaceBetween,
      children: List.generate(
        bars.length,
        (index) => GestureDetector(
          onTap: () => onTap?.call(bars[index]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 5),
                decoration: BoxDecoration(shape: BoxShape.circle, color: bars[index].color),
              ),
              Text(bars[index].label),
            ],
          ),
        ),
      ),
    );
  }
}
