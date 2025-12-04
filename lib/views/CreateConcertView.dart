import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gigmap_mobile_flutter/services/CloudinaryService.dart';
import 'package:gigmap_mobile_flutter/services/GoogleMapsService.dart';
import 'package:gigmap_mobile_flutter/services/TokenStorage.dart';
import 'package:gigmap_mobile_flutter/repository/ConcertRepository.dart';

class CreateConcertView extends StatefulWidget {
  const CreateConcertView({super.key});

  @override
  State<CreateConcertView> createState() => _CreateConcertViewState();
}

class _CreateConcertViewState extends State<CreateConcertView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageController = TextEditingController();

  final _capacityController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _venueAddressController = TextEditingController();

  String? _selectedGenre;
  String? _selectedPlatform;
  String? _selectedStatus;

  final Color wine = const Color(0xFF5C0F1A);


  final List<String> _genres = [
    'ROCK',
    'POP',
    'ELECTRONICA',
    'URBANO',
    'JAZZ',
    'INDIE',
    'CLASICO',
    'METAL',
    'FOLK',
    'COUNTRY',
    'REGGAE',
    'BLUES',
    'ALTERNATIVE',
    'PUNK',
    'SOUL',
    'FUNK',
    'R_AND_B',
    'LATIN',
    'WORLD',
    'HIP_HOP',
    'CLASSICAL',
    'ELECTRONIC',
    'OTHER'
  ];


  final List<String> _statuses = [
    'BORRADOR',
    'PUBLICADO',
    'ENCURSO',
    'FINALIZADO',
    'CANCELADO'
  ];

  final List<String> _platforms = [
    'Teleticket',
    'Joinnus',
    'Ticketmaster',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    _capacityController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
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

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Subiendo imagen...")));

    final url = await CloudinaryService.uploadImage(file);

    if (url != null) {
      _imageController.text = url;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error al subir imagen")));
    }
  }

  Future<void> _handleCreateConcert() async {
    if (!_formKey.currentState!.validate()) return;

    final capacity = int.tryParse(_capacityController.text);
    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Capacidad inválida")),
      );
      return;
    }

    final dateIso =
        "${_yearController.text}-${_monthController.text.padLeft(2, '0')}-${_dayController.text.padLeft(2, '0')}T00:00:00.000Z";

    final latlng =
    await GoogleMapsService.getLatLngFromAddress(_venueAddressController.text);

    if (latlng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se encontró ubicación")),
      );
      return;
    }

    final user = await TokenStorage.getUserData();

    final concertBody = {
      "title": _nameController.text,
      "description": _descriptionController.text,
      "imageUrl": _imageController.text,
      "date": dateIso,
      "venue": {
        "name": _venueNameController.text,
        "address": _venueAddressController.text,
        "latitude": latlng["lat"],
        "longitude": latlng["lng"],
        "capacity": capacity,
      },
      "genre": _selectedGenre ?? "OTHER",
      "status": _selectedStatus ?? "BORRADOR",
      "platform": {
        "platformName": _selectedPlatform,
        "platformImage": ""
      },
      "userId": user?.id
    };

    final result = await ConcertRepository.createConcert(concertBody);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Concierto creado!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al crear concierto")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: wine),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GigMap",
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // NOMBRE
              const Text("Nombre del concierto"),
              SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _fieldDecoration("Nombre"),
              ),

              SizedBox(height: 20),

              // FECHA
              const Text("Fecha del concierto"),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dayController,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: _fieldDecoration("DD").copyWith(counterText: ""),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: _fieldDecoration("MM").copyWith(counterText: ""),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: _fieldDecoration("YYYY").copyWith(counterText: ""),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // GÉNERO
              const Text("Género"),
              SizedBox(height: 8),
              DropdownButtonFormField(
                value: _selectedGenre,
                items: _genres.map((g) => DropdownMenuItem(
                  value: g,
                  child: Text(g),
                )).toList(),
                onChanged: (v) => setState(() => _selectedGenre = v),
                decoration: _fieldDecoration("Selecciona género"),
              ),

              SizedBox(height: 20),

              // ESTADO
              const Text("Estado del concierto"),
              SizedBox(height: 8),
              DropdownButtonFormField(
                value: _selectedStatus,
                items: _statuses.map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s),
                )).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v),
                decoration: _fieldDecoration("Selecciona estado"),
              ),

              SizedBox(height: 20),

              // DESCRIPCIÓN
              const Text("Descripción"),
              SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _fieldDecoration("Descripción del evento"),
              ),

              SizedBox(height: 20),

              // IMAGEN
              const Text("Imagen"),
              SizedBox(height: 8),
              TextFormField(
                controller: _imageController,
                readOnly: true,
                decoration: _fieldDecoration("Seleccionar imagen").copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickAndUploadImage,
                  ),
                ),
              ),

              SizedBox(height: 20),

              // PLATAFORMA
              const Text("Plataforma"),
              SizedBox(height: 8),
              DropdownButtonFormField(
                value: _selectedPlatform,
                items: _platforms.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p),
                )).toList(),
                onChanged: (v) => setState(() => _selectedPlatform = v),
                decoration: _fieldDecoration("Selecciona plataforma"),
              ),

              SizedBox(height: 20),

              const Text("Nombre del recinto",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              TextFormField(
                controller: _venueNameController,
                decoration: _fieldDecoration("Ej: Estadio Nacional"),
              ),

              SizedBox(height: 20),

              const Text("Dirección del recinto",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              SizedBox(height: 8),
              TextFormField(
                controller: _venueAddressController,
                decoration: _fieldDecoration("Ingresa la dirección exacta"),
              ),
              SizedBox(height: 20),

              // CAPACIDAD
              const Text("Capacidad del recinto"),
              SizedBox(height: 8),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration("Capacidad"),
              ),

              SizedBox(height: 30),

              // BOTÓN CREAR
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleCreateConcert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: wine,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Crear concierto",
                    style: TextStyle(color: Colors.white),
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
