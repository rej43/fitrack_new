// lib/core/components/body_type_selector.dart
import 'package:flutter/material.dart';
import 'package:fitrack/common/color_extension.dart';
// ignore: unused_import
import 'package:fitrack/common_widget/round_button.dart';

enum BodyType { SKINNY, FAT, NORMAL, ATHLETE, BULKY, MUSCULAR, OBESE }

class BodyTypeSelector extends StatefulWidget {
  final ValueChanged<BodyType?>? onChanged;
  final BodyType? initialValue;

  const BodyTypeSelector({Key? key, this.onChanged, this.initialValue})
    : super(key: key);

  @override
  _BodyTypeSelectorState createState() => _BodyTypeSelectorState();
}

class _BodyTypeSelectorState extends State<BodyTypeSelector> {
  late BodyType? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your body type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              BodyType.values.map((type) {
                return _buildTypeChip(type);
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeChip(BodyType type) {
    final isSelected = _selectedType == type;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = type);
        widget.onChanged?.call(type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TColor.primaryColor1 : TColor.lightgrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? TColor.primaryColor1 : TColor.grey,
          ),
        ),
        child: Text(
          _getDisplayName(type),
          style: TextStyle(
            color: isSelected ? Colors.white : TColor.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  String _getDisplayName(BodyType type) {
    switch (type) {
      case BodyType.SKINNY:
        return 'Skinny';
      case BodyType.FAT:
        return 'Fat';
      case BodyType.NORMAL:
        return 'Normal';
      case BodyType.ATHLETE:
        return 'Athlete';
      case BodyType.BULKY:
        return 'Bulky';
      case BodyType.MUSCULAR:
        return 'Muscular';
      case BodyType.OBESE:
        return 'Obese';
    }
  }
}
