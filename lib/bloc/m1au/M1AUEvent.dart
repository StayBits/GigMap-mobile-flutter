part of 'M1AUBloc.dart';

abstract class M1AUEvent {}

/// Evento para enviar un mensaje al chatbot
class SendMessageEvent extends M1AUEvent {
  final String message;
  final int? userId;

  SendMessageEvent({
    required this.message,
    this.userId,
  });
}

/// Evento para limpiar el error actual
class DismissErrorEvent extends M1AUEvent {}

/// Evento para limpiar todo el historial del chat
class ClearChatHistoryEvent extends M1AUEvent {}