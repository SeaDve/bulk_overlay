import 'package:flutter/material.dart';

class FilterSlider extends StatelessWidget {
  const FilterSlider({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.min,
    required this.max,
    this.divisions,
    this.onChanged,
    this.onReset,
  });

  final IconData icon;
  final double value;
  final String label;
  final double min;
  final double max;
  final int? divisions;

  final ValueChanged<double>? onChanged;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 240),
            child: Slider(
              label: label,
              min: min,
              max: max,
              divisions: divisions,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        IconButton(onPressed: onReset, icon: Icon(Icons.refresh)),
      ],
    );
  }
}
