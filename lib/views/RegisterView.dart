import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/bloc/auth/AuthBloc.dart';
import 'package:gigmap_mobile_flutter/views/ConcertList.dart';
import 'package:gigmap_mobile_flutter/views/LoginView.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  /// 'ARTIST' o 'FAN' (mapeas luego a lo que tu backend espere)
  String _selectedRole = 'ARTIST';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5C0F1A);
    const labelColor = Color(0xFF6E6E6E);
    const hintColor = Color(0xFFB0B0B0);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoadingState) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthAuthenticatedState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Concertlist()),
          );
        } else if (state is AuthErrorActionState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Flecha back
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),

                const SizedBox(height: 16),

                // Avatar circular
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: const AssetImage('assets/img/logo_gigmap.png',),
                  ),
                ),

                const SizedBox(height: 24),

                // Título
                const Center(
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // EMAIL
                      const Text(
                        'Email',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu correo electrónico',
                          hintStyle: const TextStyle(color: hintColor),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: Color(0xFFD3D3D3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: primaryColor, width: 1.3),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Por favor ingresa un email válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD
                      const Text(
                        'Contrasena',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu contrasena',
                          hintStyle: const TextStyle(color: hintColor),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: Color(0xFFD3D3D3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: primaryColor, width: 1.3),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa una contrasena';
                          }
                          if (value.length < 8 || value.length > 32) {
                            return 'La contrasena debe tener entre 8 y 32 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '8-32 caracteres, incluyendo letras, números y caracteres especiales',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const SizedBox(height: 22),

                      // TIPO DE USUARIO
                      const Text(
                        'Tipo de usuario',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _UserTypeChip(
                              label: 'Artista',
                              selected: _selectedRole == 'ARTIST',
                              onTap: () {
                                setState(() => _selectedRole = 'ARTIST');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _UserTypeChip(
                              label: 'Fan',
                              selected: _selectedRole == 'FAN',
                              onTap: () {
                                setState(() => _selectedRole = 'FAN');
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // USERNAME
                      const Text(
                        'Username',
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Ingresa tu username',
                          hintStyle: const TextStyle(color: hintColor),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: Color(0xFFD3D3D3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                            const BorderSide(color: primaryColor, width: 1.3),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF9F9F9),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa un username';
                          }
                          if (value.length < 3) {
                            return 'El username debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Elige tu username. Puedes cambiarlo después en la configuración de usuario.',
                        style: TextStyle(
                          color: hintColor,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // BOTÓN SIGUIENTE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                AuthRegisterEvent(
                                  email:
                                  _emailController.text.trim(),
                                  username: _usernameController.text
                                      .trim(),
                                  password: _passwordController.text,
                                  role: _selectedRole,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            'Siguiente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // YA TIENES CUENTA? INICIA SESION
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Ya tienes una cuenta? ',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginView(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Inicia sesion',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Botoncitos tipo chip para "Artista" / "Fan"
class _UserTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UserTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5C0F1A);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? primaryColor : const Color(0xFFD3D3D3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
