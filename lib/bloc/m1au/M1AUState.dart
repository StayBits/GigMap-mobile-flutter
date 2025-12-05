part of 'M1AUBloc.dart';

abstract class M1AUState {
  final List<ChatMessage> messages;
  final List<M1AUConcertCard> concerts;
  final bool isLoading;
  final String? error;

  const M1AUState({
    this.messages = const [],
    this.concerts = const [],
    this.isLoading = false,
    this.error,
  });
}

/// Estado inicial (sin mensajes)
class M1AUInitial extends M1AUState {
  const M1AUInitial() : super();
}

/// Estado de carga (esperando respuesta del bot)
class M1AULoading extends M1AUState {
  const M1AULoading({
    required List<ChatMessage> messages,
    List<M1AUConcertCard> concerts = const [],
  }) : super(
    messages: messages,
    concerts: concerts,
    isLoading: true,
  );
}

/// Estado exitoso (respuesta recibida)
class M1AUSuccess extends M1AUState {
  const M1AUSuccess({
    required List<ChatMessage> messages,
    required List<M1AUConcertCard> concerts,
  }) : super(
    messages: messages,
    concerts: concerts,
    isLoading: false,
  );
}

/// Estado de error (mostrar mensaje al usuario)
class M1AUError extends M1AUState {
  const M1AUError({
    required String error,
    required List<ChatMessage> messages,
    List<M1AUConcertCard> concerts = const [],
  }) : super(
    messages: messages,
    concerts: concerts,
    isLoading: false,
    error: error,
  );
}