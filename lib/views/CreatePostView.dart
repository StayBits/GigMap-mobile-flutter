import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../repository/PostRepository.dart';
import '../services/CloudinaryService.dart';
import '../services/TokenStorage.dart';

class CreatePostView extends StatefulWidget {
  final int communityId;

  const CreatePostView({
    super.key,
    required this.communityId,
  });

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  final Color wine = const Color(0xFF5C0F1A);

  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    final file = File(picked.path);

    setState(() => _isUploadingImage = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subiendo imagen...")),
    );

    final url = await CloudinaryService.uploadImage(file);

    if (!mounted) return;

    setState(() => _isUploadingImage = false);

    if (url != null) {
      setState(() => _uploadedImageUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Imagen subida correctamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al subir imagen")),
      );
    }
  }

  Future<void> _handleCreatePost() async {
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();

    if (content.isEmpty && (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Agrega texto o imagen antes de publicar"),
        ),
      );
      return;
    }

    final user = await TokenStorage.getUserData();
    if (user == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes iniciar sesión para publicar")),
      );
      return;
    }

    final newPost = await PostRepository.createPost(
      communityId: widget.communityId,
      userId: user.id,
      content: content,
      imageUrl: _uploadedImageUrl,
    );

    if (!mounted) return;

    if (newPost != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Publicación creada correctamente")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al crear la publicación")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: wine),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "GigMap",
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Crear publicación",
                style: TextStyle(
                  color: Color(0xFF5C0F1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 24),


              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: _fieldDecoration("Escribe tu publicación..."),
                validator: (value) {
                  if ((value == null || value.trim().isEmpty) &&
                      (_uploadedImageUrl == null ||
                          _uploadedImageUrl!.isEmpty)) {
                    return "Escribe algo o selecciona una imagen";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wine,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isUploadingImage
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.image, color: Colors.white),
                  label: Text(
                    _isUploadingImage
                        ? "Subiendo imagen..."
                        : "Seleccionar imagen",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (_uploadedImageUrl != null) ...[
                const Text(
                  "Imagen lista para publicar",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _uploadedImageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleCreatePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wine,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Publicar",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
