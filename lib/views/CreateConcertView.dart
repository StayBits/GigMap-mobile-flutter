import 'package:flutter/material.dart';

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
  final _venueController = TextEditingController();

  String? _selectedGenre;
  String? _selectedPlatform;

  final Color wine = const Color(0xFF5C0F1A);

  final List<String> _genres = [
    'Pop',
    'Rock',
    'K-pop',
    'Reggaetón',
    'Indie',
    'Otro',
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
    _venueController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: wine, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      /// APP BAR igual que las otras vistas
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: wine),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'GigMap',
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: wine),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Nombre del concierto
                const Text(
                  'Nombre del concierto',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration:
                  _fieldDecoration('Ingresa el nombre del concierto'),
                ),

                const SizedBox(height: 20),

                /// Fecha
                const Text(
                  'Ingresa la fecha del concierto',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        decoration: _fieldDecoration('DD').copyWith(
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _monthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        decoration: _fieldDecoration('DD').copyWith(
                          counterText: '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        decoration: _fieldDecoration('YYYY').copyWith(
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Género
                const Text(
                  'Género',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedGenre,
                  decoration:
                  _fieldDecoration('Selecciona el género musical'),
                  icon: Icon(Icons.keyboard_arrow_down, color: wine),
                  items: _genres
                      .map(
                        (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGenre = value;
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// Descripción
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 400,
                  decoration: _fieldDecoration('Ingresa una descripción')
                      .copyWith(counterText: ''),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa una descripción del evento de máximo 400 caracteres.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                /// Imagen
                const Text(
                  'Imagen',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _imageController,
                  readOnly: true,
                  decoration: _fieldDecoration('Carga una Imagen').copyWith(
                    suffixIcon: Container(
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: wine,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onTap: () {
                    // TODO: aquí iría el picker de imagen + subida a Cloudinary
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa únicamente un archivo .jpg o .png.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                /// Plataforma
                const Text(
                  'Plataforma',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPlatform,
                  decoration:
                  _fieldDecoration('Selecciona la plataforma'),
                  icon: Icon(Icons.keyboard_arrow_down, color: wine),
                  items: _platforms
                      .map(
                        (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p),
                    ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value;
                    });
                  },
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa la plataforma de venta de entradas.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 20),

                /// Recinto
                const Text(
                  'Recinto',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _venueController,
                  decoration:
                  _fieldDecoration('Ingresa el nombre del recinto'),
                ),

                const SizedBox(height: 32),

                /// BOTÓN CREAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: aquí luego llamas a tu BLoC / servicio para crear el concierto
                      if (_formKey.currentState?.validate() ?? false) {
                        // por ahora solo mostramos un snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Concierto creado (dummy).'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: wine,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Crear',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
