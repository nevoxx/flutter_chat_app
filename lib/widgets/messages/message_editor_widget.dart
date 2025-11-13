import 'package:flutter/material.dart';

class MessageEditorWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const MessageEditorWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        isDense: true,
      ),
      maxLines: 5,
      minLines: 1,
      textInputAction: TextInputAction.newline,
      onSubmitted: (_) => onSubmit(),
    );
  }
}

