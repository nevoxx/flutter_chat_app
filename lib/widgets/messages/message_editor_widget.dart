import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageEditorWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const MessageEditorWidget({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<MessageEditorWidget> createState() => _MessageEditorWidgetState();
}

class _MessageEditorWidgetState extends State<MessageEditorWidget> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Handle Enter key
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
          
          if (!isShiftPressed) {
            // Enter without Shift - send message
            widget.onSubmit();
            return KeyEventResult.handled; // Prevent default behavior
          }
          // Shift+Enter - let TextField handle it (create new line)
          return KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
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
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}

