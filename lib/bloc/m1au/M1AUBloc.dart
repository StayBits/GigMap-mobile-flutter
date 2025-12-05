import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../models/m1au/M1AUBotReply.dart';
import '../../models/m1au/ChatMessage.dart';
import '../../repository/M1AURepository.dart';

part 'M1AUEvent.dart';
part 'M1AUState.dart';

class M1AUBloc extends Bloc<M1AUEvent, M1AUState> {
  final M1AURepository _repository;

  M1AUBloc({M1AURepository? repository})
      : _repository = repository ?? M1AURepository(),
        super(const M1AUInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<DismissErrorEvent>(_onDismissError);
    on<ClearChatHistoryEvent>(_onClearChatHistory);
  }

  /// Maneja el envío de mensajes al chatbot
  Future<void> _onSendMessage(
      SendMessageEvent event,
      Emitter<M1AUState> emit,
      ) async {
    // Validar mensaje vacío
    final trimmedMessage = event.message.trim();
    if (trimmedMessage.isEmpty) return;

    // Agregar mensaje del usuario al historial
    final userMessage = ChatMessage(
      text: trimmedMessage,
      isUser: true,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(userMessage);

    // Emitir estado de carga manteniendo historial
    emit(M1AULoading(
      messages: updatedMessages,
      concerts: state.concerts,
    ));

    try {
      // Llamar al repository
      final reply = await _repository.sendMessage(
        message: trimmedMessage,
        userId: event.userId,
      );

      // Agregar respuesta del bot al historial
      final botMessage = ChatMessage(
        text: reply.message,
        isUser: false,
      );

      final finalMessages = List<ChatMessage>.from(updatedMessages)
        ..add(botMessage);

      // Emitir estado exitoso
      emit(M1AUSuccess(
        messages: finalMessages,
        concerts: reply.concerts,
      ));
    } on M1AUException catch (e) {
      // Error controlado del repository
      emit(M1AUError(
        error: e.message,
        messages: updatedMessages,
        concerts: state.concerts,
      ));
    } catch (e) {
      // Error inesperado
      emit(M1AUError(
        error: 'Ups, algo salió mal. Por favor intenta nuevamente, miau miau.',
        messages: updatedMessages,
        concerts: state.concerts,
      ));
    }
  }

  /// Limpia el error actual (para que el usuario pueda reintentar)
  void _onDismissError(
      DismissErrorEvent event,
      Emitter<M1AUState> emit,
      ) {
    if (state is M1AUError) {
      emit(M1AUSuccess(
        messages: state.messages,
        concerts: state.concerts,
      ));
    }
  }

  /// Limpia todo el historial del chat (útil para "reset")
  void _onClearChatHistory(
      ClearChatHistoryEvent event,
      Emitter<M1AUState> emit,
      ) {
    emit(const M1AUInitial());
  }
}