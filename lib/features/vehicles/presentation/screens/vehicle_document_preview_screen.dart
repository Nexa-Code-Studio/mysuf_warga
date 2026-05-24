import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../core/theme/app_colors.dart';

class VehicleDocumentPreviewScreen extends StatelessWidget {
  final String title;
  final String mimeType;
  final List<int> bytes;

  const VehicleDocumentPreviewScreen({
    super.key,
    required this.title,
    required this.mimeType,
    required this.bytes,
  });

  @override
  Widget build(BuildContext context) {
    final data = Uint8List.fromList(bytes);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: mimeType.startsWith('image/')
            ? InteractiveViewer(
                child: Center(child: Image.memory(data)),
              )
            : mimeType == 'application/pdf'
                ? SfPdfViewer.memory(data)
                : Center(
                    child: Text(
                      'Format dokumen belum didukung untuk preview.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
      ),
    );
  }
}
