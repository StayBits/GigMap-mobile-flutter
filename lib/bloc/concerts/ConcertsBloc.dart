import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gigmap_mobile_flutter/repository/ConcertRepository.dart';
import 'package:gigmap_mobile_flutter/models/ConcertDataModel.dart';

part 'ConcertsState.dart';
part 'ConcertsEvent.dart';

class ConcertsBloc extends Bloc<ConcertsEvent, ConcertState> {
  ConcertsBloc() : super(ConcertsInitial()) {
    on<ConcertInitialFetchEvent>(_fetchAll);
    on<FetchConcertByIdEvent>(_fetchById);
    on<FetchConcertsByGenreEvent>(_fetchByGenre);
    on<FetchConcertsByArtistEvent>(_fetchByArtist);
    on<FetchConcertsByUserEvent>(_fetchByUser);
    on<CreateConcertEvent>(_createConcert);
    on<UpdateConcertEvent>(_updateConcert);
    on<DeleteConcertEvent>(_deleteConcert);
    on<AddAttendeeEvent>(_addAttendee);
    on<RemoveAttendeeEvent>(_removeAttendee);
  }

  Future<void> _fetchAll(event, emit) async {
    emit(ConcertActionState());
    final concerts = await ConcertRepository.fetchConcerts();
    emit(ConcertFetchingSuccessFullState(concerts: concerts));
  }

  Future<void> _fetchById(FetchConcertByIdEvent event, emit) async {
    emit(ConcertActionState());
    final concert = await ConcertRepository.fetchConcertById(event.concertId);
    if (concert != null) {
      emit(ConcertByIdSuccessState(concert: concert));
    } else {
      emit(ConcertsErrorState(message: "No encontrado"));
    }
  }

  Future<void> _fetchByGenre(FetchConcertsByGenreEvent event, emit) async {
    emit(ConcertActionState());
    final concerts = await ConcertRepository.fetchByGenre(event.genre);
    emit(ConcertFetchingSuccessFullState(concerts: concerts));
  }

  Future<void> _fetchByArtist(FetchConcertsByArtistEvent event, emit) async {
    emit(ConcertActionState());
    final concerts = await ConcertRepository.fetchByArtist(event.artistId);
    emit(ConcertFetchingSuccessFullState(concerts: concerts));
  }

  Future<void> _fetchByUser(FetchConcertsByUserEvent event, emit) async {
    emit(ConcertActionState());
    final concerts = await ConcertRepository.fetchByUser(event.userId);
    emit(ConcertFetchingSuccessFullState(concerts: concerts));
  }

  Future<void> _createConcert(CreateConcertEvent event, emit) async {
    emit(ConcertActionState());
    final concert = await ConcertRepository.createConcert(event.data);
    concert != null
        ? emit(ConcertCreatedSuccessState(concert: concert))
        : emit(ConcertsErrorState(message: "No se pudo crear"));
  }

  Future<void> _updateConcert(UpdateConcertEvent event, emit) async {
    emit(ConcertActionState());
    final concert =
    await ConcertRepository.updateConcert(event.concertId, event.data);
    concert != null
        ? emit(ConcertUpdatedSuccessState(concert: concert))
        : emit(ConcertsErrorState(message: "No se pudo actualizar"));
  }

  Future<void> _deleteConcert(DeleteConcertEvent event, emit) async {
    emit(ConcertActionState());
    final ok = await ConcertRepository.deleteConcert(event.concertId);
    ok
        ? emit(ConcertDeletedSuccessState(concertId: event.concertId))
        : emit(ConcertsErrorState(message: "No se pudo eliminar"));
  }

  Future<void> _addAttendee(AddAttendeeEvent event, emit) async {
    emit(ConcertActionState());
    final ok = await ConcertRepository.addAttendee(event.concertId, event.userId);
    ok
        ? emit(AttendeeAddedSuccessState())
        : emit(ConcertsErrorState(message: "Error agregando asistente"));
  }

  Future<void> _removeAttendee(RemoveAttendeeEvent event, emit) async {
    emit(ConcertActionState());
    final ok =
    await ConcertRepository.removeAttendee(event.concertId, event.userId);
    ok
        ? emit(AttendeeRemovedSuccessState())
        : emit(ConcertsErrorState(message: "Error quitando asistente"));
  }
}