import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/ocr_service.dart';
import '../../../../shared/widgets/camera_overlay_painter.dart';

class KtpCaptureScreen extends StatefulWidget {
  const KtpCaptureScreen({super.key});

  @override
  State<KtpCaptureScreen> createState() => _KtpCaptureScreenState();
}

class _KtpCaptureScreenState extends State<KtpCaptureScreen> {
  CameraController? _controller;
  bool _isInitializing = true;
  bool _isProcessing = false;
  final OcrService _ocrService = OcrService();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);
      
      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _controller!.initialize();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _captureKtp() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile imageFile = await _controller!.takePicture();
      final File file = File(imageFile.path);
      
      final ktpData = await _ocrService.processImage(file);
      
      if (mounted) {
        context.push('/auth/ocr-confirm', extra: ktpData);
      }
    } catch (e) {
      debugPrint('Error capturing or processing KTP: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memproses KTP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Kamera tidak tersedia')),
      );
    }

    final size = MediaQuery.of(context).size;
    
    // KTP aspect ratio is roughly 1.58 (85.6mm / 53.98mm)
    final ktpWidth = size.width * 0.85;
    final ktpHeight = ktpWidth / 1.58;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2.5),
      width: ktpWidth,
      height: ktpHeight,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          CustomPaint(
            painter: CameraOverlayPainter(
              cutoutRect: cutoutRect,
            ),
          ),
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: const Text(
              'Posisikan KTP Anda di dalam bingkai',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : GestureDetector(
                      onTap: _captureKtp,
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.red, // Pertamina Red equivalent
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
