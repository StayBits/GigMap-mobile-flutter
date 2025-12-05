import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/bloc/m1au/M1AUBloc.dart';
import 'package:gigmap_mobile_flutter/views/ChatBubbleM1AU.dart';
import 'package:gigmap_mobile_flutter/views/ConcertCardM1AU.dart';

class M1AUChatModal extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String artistId) onNavigateToArtist;
  final Function(String concertId) onNavigateToConcert;

  const M1AUChatModal({
    Key? key,
    required this.onClose,
    required this.onNavigateToArtist,
    required this.onNavigateToConcert,
  }) : super(key: key);

  @override
  State<M1AUChatModal> createState() => M1AUChatModalState();
}

class M1AUChatModalState extends State<M1AUChatModal>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  void _sendMessage(BuildContext context) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<M1AUBloc>().add(SendMessageEvent(
      message: text,
      userId: null, // Puedes pasar el userId si está disponible
    ));

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo blur + oscuro
        FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _handleClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        ),

        // Modal deslizable
        Align(
          alignment: Alignment.centerRight,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                margin: const EdgeInsets.only(bottom: 70),
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.62,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withOpacity(0.95),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Chat con M1AU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: _handleClose,
                            icon: const Icon(Icons.close, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    // Historial de mensajes
                    Expanded(
                      child: BlocBuilder<M1AUBloc, M1AUState>(
                        builder: (context, state) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: state.messages.length + state.concerts.length,
                            itemBuilder: (context, index) {
                              if (index < state.messages.length) {
                                return ChatBubbleM1AU(message: state.messages[index]);
                              }

                              final concertIndex = index - state.messages.length;
                              final concert = state.concerts[concertIndex];

                              return ConcertCardM1AU(
                                concert: concert,
                                onNavigateToArtist: () {
                                  if (concert.artist?.id != null) {
                                    widget.onNavigateToArtist(concert.artist!.id!);
                                  }
                                },
                                onNavigateToConcert: () {
                                  widget.onNavigateToConcert(concert.id);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Input + Botón
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: BlocBuilder<M1AUBloc, M1AUState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              TextField(
                                controller: _controller,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Pregúntale a M1AU...',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(context),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.isLoading
                                      ? null
                                      : () => _sendMessage(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5C0F1A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    state.isLoading ? 'Miau pensando...' : 'Enviar',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              if (state.error != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  state.error!,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}