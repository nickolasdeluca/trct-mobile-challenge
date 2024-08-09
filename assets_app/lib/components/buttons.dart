import 'package:assets_app/constants/palette.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.controller,
  });

  final IconData icon;
  final String label;
  final ValueNotifier<bool> controller;

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  late ValueNotifier<bool> _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  bool get toggled => _controller.value;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _controller.value = !_controller.value;
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(
          toggled ? Palette.chefchaouenBlue : Colors.white,
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
      icon: Icon(
        widget.icon,
        color: toggled ? Colors.white : Palette.slateGrey,
      ),
      label: Text(
        widget.label,
        style: TextStyle(
          color: toggled ? Colors.white : Palette.slateGrey,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
