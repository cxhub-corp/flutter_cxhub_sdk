import 'package:flutter/material.dart';

class SimpleField extends StatelessWidget {
  final String name;
  final Widget child;
  final String? actionName;
  final VoidCallback? action;

  const SimpleField({
    super.key,
    required this.name,
    required this.child,
    this.actionName,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name),
                  child,
                ],
              ),
            ),
            const SizedBox(width: 16),
            actionName != null
                ? MaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16.0)),
                    ),
                    padding: const EdgeInsets.all(8),
                    onPressed: action,
                    child: Text(actionName!),
                  )
                : const SizedBox(width: 0)
          ],
        ),
      ),
    );
  }
}
