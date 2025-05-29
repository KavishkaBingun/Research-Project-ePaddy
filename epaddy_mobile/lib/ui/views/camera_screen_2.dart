import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'image_preview_screen_2.dart'; // Screen to show preview

class CameraScreen2 extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen2> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isFlashOn = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController != null) {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
          _isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      XFile file = await _cameraController!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen2(imagePath: file.path),
        ),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen2(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(
                      _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black54,
                      ),
                      child: Icon(Icons.image, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _captureImage,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.black, size: 30),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
