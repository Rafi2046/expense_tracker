import 'package:material_symbols_icons/symbols.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PartyAvatarPicker extends StatefulWidget {
  final String? pickedImagePath;
  final Uint8List? pickedImageBytes;
  final Function(String? path, Uint8List? bytes) onImagePicked;

  const PartyAvatarPicker({
    super.key,
    this.pickedImagePath,
    this.pickedImageBytes,
    required this.onImagePicked,
  });

  @override
  State<PartyAvatarPicker> createState() => _PartyAvatarPickerState();
}

class _PartyAvatarPickerState extends State<PartyAvatarPicker> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          widget.onImagePicked(null, bytes);
        } else {
          widget.onImagePicked(image.path, null);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              // Circular Profile Image Container with modern shadow and border
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A5C7A), Color(0xFF2D3748)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildAvatarImage()),
              ),
              // Camera Icon Badge Overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Symbols.camera_alt_rounded,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarImage() {
    if (kIsWeb && widget.pickedImageBytes != null) {
      return Image.memory(
        widget.pickedImageBytes!,
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      );
    } else if (!kIsWeb && widget.pickedImagePath != null) {
      return Image.file(
        File(widget.pickedImagePath!),
        fit: BoxFit.cover,
        width: 80,
        height: 80,
      );
    } else {
      return const Icon(Symbols.person_rounded, color: Colors.white, size: 44);
    }
  }
}
