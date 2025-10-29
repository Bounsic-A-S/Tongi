import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LangModelCard extends StatelessWidget {
  final String code;
  final String name;
  final Function(String code) onDelete;
  final VoidCallback callback;

  const LangModelCard({
    super.key,
    required this.code,
    required this.name,
    required this.onDelete,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            SizedBox(width: 5),
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.green.shade100,
              child: Text(
                code.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () {
                _confirmDelete(context);
              },
              icon: Icon(Icons.delete, color: Colors.red.shade300),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // permite cerrar tocando fuera del dialog
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // bordes redondeados
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const SizedBox(height: 15),
            Text(
              "Eliminar modelo $name?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(code);
              callback();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }
}
