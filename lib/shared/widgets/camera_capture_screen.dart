import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum CameraOverlayType {
  ktp,
  selfieKtp,
}

class CameraCaptureScreen extends StatefulWidget {
  final String title;
  final String actionLabel;
  final String helperText;
  final CameraLensDirection lensDirection;
  final CameraOverlayType overlayType;

  const CameraCaptureScreen({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.helperText,
    required this.lensDirection,
    required this.overlayType,
  });

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }


  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == widget.lensDirection,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      setState(() {
        _controller = controller;
        _initializeFuture = controller.initialize();
      });
      await _initializeFuture;
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    } on CameraException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.description ?? 'Gagal membuka kamera.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal membuka kamera.';
        });
      }
    }
  }

  Future<void> _capture() async {
    if (_controller == null || _initializeFuture == null) {
      return;
    }
    setState(() {
      _isCapturing = true;
    });
    try {
      await _initializeFuture;
      final file = await _controller!.takePicture();
      if (mounted) {
        Navigator.of(context).pop(file.path);
      }
    } on CameraException catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengambil foto. Coba lagi.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Text(
                widget.helperText,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
            ),
            Expanded(
              child: _buildPreview(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _capture,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(widget.actionLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_outlined,
                  color: Colors.white70, size: 40),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    final initializeFuture = _initializeFuture;
    if (controller == null || initializeFuture == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return FutureBuilder<void>(
      future: initializeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            CustomPaint(
              painter: _CameraOverlayPainter(widget.overlayType),
            ),
          ],
        );
      },
    );
  }
}

class _CameraOverlayPainter extends CustomPainter {
  final CameraOverlayType overlayType;

  _CameraOverlayPainter(this.overlayType);

  @override
  void paint(Canvas canvas, Size size) {
    final layerRect = Offset.zero & size;
    canvas.saveLayer(layerRect, Paint());
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.55);
    canvas.drawRect(layerRect, overlayPaint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.85);

    if (overlayType == CameraOverlayType.ktp) {
      final frameSize = Size(size.width * 0.78, size.height * 0.28);
      final frameRect = Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: frameSize.width,
        height: frameSize.height,
      );
      final frameRRect = RRect.fromRectAndRadius(
        frameRect,
        const Radius.circular(16),
      );
      canvas.drawRRect(frameRRect, clearPaint);
      canvas.drawRRect(frameRRect, outlinePaint);
    } else {
      final faceRadius = size.width * 0.26;
      final faceCenter = Offset(size.width / 2, size.height * 0.42);
      final faceRect = Rect.fromCircle(center: faceCenter, radius: faceRadius);
      canvas.drawOval(faceRect, clearPaint);
      canvas.drawOval(faceRect, outlinePaint);

      final ktpSize = Size(size.width * 0.5, size.height * 0.18);
      final ktpRect = Rect.fromCenter(
        center: Offset(size.width * 0.66, size.height * 0.68),
        width: ktpSize.width,
        height: ktpSize.height,
      );
      final ktpRRect = RRect.fromRectAndRadius(
        ktpRect,
        const Radius.circular(12),
      );
      canvas.drawRRect(ktpRRect, clearPaint);
      canvas.drawRRect(ktpRRect, outlinePaint);

      final helperPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.4);
      canvas.drawLine(faceCenter, ktpRect.topLeft, helperPaint);
      canvas.drawLine(faceCenter, ktpRect.topRight, helperPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CameraOverlayPainter oldDelegate) {
    return oldDelegate.overlayType != overlayType;
  }
}
