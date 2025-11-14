import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/views/ConcertList.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key, this.onLoginTap, this.onRegisterTap});

  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/img/welcome_image.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Center(
                    child: Image.asset(
                      'assets/img/logo_gigmap.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  '¡Bienvenido a GigMap!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(),

                /// inicio de sesion por ahora lleva a concertlist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Concertlist(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C0F1A),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// registro - no hace nada
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: GestureDetector(
                    onTap: onRegisterTap,
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text: '¿Nuevo en GigMap? '),
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
