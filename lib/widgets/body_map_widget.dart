import 'package:flutter/material.dart';
import '../theme.dart';

class BodyMapWidget extends StatelessWidget {
  final String? selectedArea;
  final ValueChanged<String> onAreaSelected;

  const BodyMapWidget({
    super.key,
    required this.selectedArea,
    required this.onAreaSelected,
  });

  static const _areas = [
    'Head', 'Neck', 'Left Shoulder', 'Right Shoulder',
    'Chest', 'Left Arm', 'Right Arm', 'Abdomen',
    'Lower Back', 'Left Leg', 'Right Leg', 'Feet',
  ];

  @override
  Widget build(BuildContext ctx) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _areas
          .map((area) => GestureDetector(
        onTap: () => onAreaSelected(area),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selectedArea == area ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            area,
            style: TextStyle(
              color: selectedArea == area ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ))
          .toList(),
    );
  }
}
