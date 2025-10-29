import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/logic/controllers/lang_selector_controller.dart';
import 'package:frontend/ui/widgets/language_selector.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class GalleryView extends StatefulWidget {
  GalleryView({
    super.key,
    this.text,
    required this.title,
    required this.onImage,
    required this.onDetectorViewModeChanged,
  });

  final String title;
  String? text;
  final Function(InputImage inputImage, {bool setTextRes}) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  ImagePicker? _imagePicker;
  bool _isProcessing = false;
  String? _actualImagePath;

  @override
  void initState() {
    super.initState();
    LangSelectorController().addListener(_updateTranslation);
    LangSelectorController().swapText = _updateTranslation;
    _imagePicker = ImagePicker();
    widget.text = "";
  }

  @override
  void dispose() {
    LangSelectorController().removeListener(_updateTranslation);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.black,
      //   foregroundColor: Colors.white,
      //   title: Text(widget.title),
      //   actions: [
      //     Padding(
      //       padding: EdgeInsets.only(right: 20.0),
      //       child: GestureDetector(
      //         onTap: widget.onDetectorViewModeChanged,
      //         child: Icon(
      //           Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: _galleryBody(),
    );
  }

  Widget _galleryBody() {
    return ListView(
      shrinkWrap: true,
      children: [
        // IconButton(
        //   onPressed: widget.onDetectorViewModeChanged,
        //   icon: Icon(Icons.keyboard_backspace_rounded),
        //   color: Colors.black,
        // ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: LanguageSelector(),
        ),
        _buildImageSection(),
        _buildButtonSection(),
        _buildTranslationResult(),
      ],
    );
  }

  Widget _buildImageSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        child: _image != null
            ? Stack(
                children: [
                  Image.file(
                    _image!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: 300,
                  ),
                ],
              )
            : Container(
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_rounded,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selecciona una imagen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desde tu galería',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildButtonSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 20),
              label: const Text(
                'Cargar imagen',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_image != null && !_isProcessing)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _image = null;
                    widget.text = "";
                    // widget.onImage(InputImage.fromFilePath(''));
                  });
                },
                icon: const Icon(Icons.close, size: 20),
                label: const Text(
                  'Eliminar imagen',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranslationResult() {
    final textLength = widget.text?.length ?? 0;
    final additionalHeight = (textLength / 50) * 40.0;
    final totalHeight = 100 + additionalHeight;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Traducción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            constraints: BoxConstraints(minHeight: 60, maxHeight: totalHeight),
            child: SingleChildScrollView(
              physics:
                  const NeverScrollableScrollPhysics(), // Desactiva el scroll interno
              child: _isProcessing
                  ? Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey.shade500,
                          ),
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  : Text(
                      widget.text!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _actualImagePath = pickedFile.path;
      _image = null;
      _processFile();
    }
  }

  _updateTranslation() {
    if (_actualImagePath != null) {
      _processFile();
    }
  }

  Future _processFile() async {
    String path = _actualImagePath!;
    setState(() {
      _image = File(path);
      _isProcessing = true;
    });
    final inputImage = InputImage.fromFilePath(path);
    await widget.onImage(inputImage, setTextRes: true);
    setState(() {
      _isProcessing = false;
    });
  }
}
