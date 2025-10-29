import 'package:flutter/material.dart';
import 'package:frontend/ui/core/tongi_colors.dart';

class LangDownloadCard extends StatefulWidget {
  final String code;
  final String name;
  final Function(String code) onTap;
  final VoidCallback callback;

  const LangDownloadCard({
    super.key,
    required this.code,
    required this.name,
    required this.onTap,
    required this.callback,
  });

  @override
  State<LangDownloadCard> createState() => _LangDownloadCardState();
}

class _LangDownloadCardState extends State<LangDownloadCard> {
  bool isDownloading = false;
  bool success = false;

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
              backgroundColor: isDownloading ? Colors.deepOrange.shade100 : Colors.grey.shade100,
              child: Text(
                widget.code.toUpperCase(),
                style: TextStyle(
                  color: isDownloading ? Colors.deepOrange : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 5),
            isDownloading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton.icon(
                    onPressed: _download,
                    style: ButtonStyle(
                      iconColor: WidgetStatePropertyAll(Colors.white),
                      foregroundColor: WidgetStatePropertyAll(Colors.white),
                      backgroundColor: WidgetStatePropertyAll(
                        TongiColors.textFill,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(8),
                        ),
                      ),
                    ),
                    label: Text("Descargar", style: TextStyle(fontSize: 14)),
                  ),
          ],
        ),
      ),
    );
  }

  void showDownloadError(BuildContext context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error en la descarga del modelo ${widget.name}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _safeSetState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _download() async {
    isDownloading = true;
    _safeSetState();
    final bool res = await widget.onTap(widget.code);
    isDownloading = false;
    _safeSetState();
    if (res) {
      _safeSetState();
      widget.callback();
    } else {
      showDownloadError(context);
    }
  }
}
