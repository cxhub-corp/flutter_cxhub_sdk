import 'package:flutter/material.dart';

class PropertyField extends StatefulWidget {
  final String name;
  final Future<MapEntry<String, String>?>? initial;
  final String? actionName;
  final Function(String, String)? action;
  final Map<String, String> types;

  const PropertyField({
    super.key,
    required this.name,
    required this.types,
    this.initial,
    this.actionName,
    this.action,
  });

  @override
  State<PropertyField> createState() => _PropertyFieldState();
}

class _PropertyFieldState extends State<PropertyField> {
  final _focusNode = FocusNode();
  final _controller = TextEditingController(text: "");
  late String _dropdownValue;

  @override
  void initState() {
    _dropdownValue = widget.types.keys.first;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.name),
            const SizedBox(height: 8.0),
            DropdownMenu<String>(
              width: double.infinity,
              initialSelection: widget.types.keys.first,
              onSelected: (val) {
                setState(() => _dropdownValue = val ?? "");
                _controller.text = "";
              },
              dropdownMenuEntries: widget.types.entries
                  .map((entry) => DropdownMenuEntry(
                        value: entry.key,
                        label: entry.value,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            TextFormField(
              focusNode: _focusNode,
              controller: _controller,
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
                      onPressed: ()=> widget.action?.call(_dropdownValue, _controller.text),
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
