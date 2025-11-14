import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gigmap_mobile_flutter/repository/ConcertRepository.dart';
import 'package:gigmap_mobile_flutter/models/ConcertDataModel.dart';

part 'ConcertsState.dart';
part 'ConcertsEvent.dart';

class ConcertsBloc extends Bloc<ConcertsEvent, ConcertState> {
  ConcertsBloc() : super(ConcertsInitial()) {

    on<ConcertInitialFetchEvent>(concertInitialFetchEvent);

  }

  Future<void> concertInitialFetchEvent(
      event, Emitter<dynamic> emit) async {

    List<ConcertDataModel> concerts =
    await ConcertRepository.fetchConcerts();

    emit(ConcertFetchingSuccessFullState(concerts: concerts));
  }
}