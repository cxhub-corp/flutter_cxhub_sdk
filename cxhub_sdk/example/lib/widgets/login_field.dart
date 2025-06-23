import 'package:flutter/material.dart';

class LoginField extends StatefulWidget {
  final String name;
  final Future<MapEntry<String, String>?>? initial;
  final String? actionName;
  final Function(String)? action;

  const LoginField({
    super.key,
    required this.name,
    this.initial,
    this.actionName,
    this.action,
  });

  @override
  State<LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController(text: "");
  @override
  void initState() {
    widget.initial?.then((value) {
      _controller.text = value?.value ?? "";
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _focusNode.unfocus();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: _controller,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: widget.name,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            widget.actionName != null
                ? MaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    padding: const EdgeInsets.all(8),
                    onPressed: () => widget.action?.call(_controller.text),
                    child: Text(widget.actionName!),
                  )
                : const SizedBox(width: 0)
          ],
        ),
      ),
    );
  }
}
