import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  const Input({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        border: _border,
        focusedBorder: _border,
        enabledBorder: _border,
        disabledBorder: _border,
        hintText: 'Buscar Ativo ou Local',
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
