import 'package:flutter/material.dart';

class EventField extends StatefulWidget {
  final String name;
  final Future<MapEntry<String, String>?>? initial;
  final String? actionName;
  final Function(String, String)? action;

  const EventField({
    super.key,
    required this.name,
    this.initial,
    this.actionName,
    this.action,
  });

  @override
  State<EventField> createState() => _EventFieldState();
}

class _EventFieldState extends State<EventField> {
  final _focusNode = FocusNode();
  final _controllerKey = TextEditingController(text: "");
  final _controllerValue = TextEditingController(text: "");

  @override
  void initState() {
    widget.initial?.then((value) {
      _controllerKey.text = value?.key ?? "";
      //});
      //widget.initial?.then((value) {
      _controllerValue.text = value?.value ?? "";
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            const SizedBox(height: 8.0),
            TextFormField(
              focusNode: _focusNode,
              controller: _controllerKey,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Key",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              focusNode: _focusNode,
              controller: _controllerValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Value",
              ),
            ),
            widget.actionName != null
                ? Container(
                    padding: const EdgeInsets.only(top: 8),
                    alignment: Alignment.centerRight,
                    width: double.infinity,
                    child: MaterialButton(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0)),
                      ),
                      padding: const EdgeInsets.all(8),
                      onPressed: () => widget.action
                          ?.call(_controllerKey.text, _controllerValue.text),
                      child: Text(widget.actionName!),
                    ),
                  )
                : const SizedBox(width: 0)
          ],
        ),
      ),
    );
  }
}
