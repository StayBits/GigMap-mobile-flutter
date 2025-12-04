part of 'ConcertsBloc.dart';

abstract class ConcertState {}

class ConcertsInitial extends ConcertState {}

class ConcertActionState extends ConcertState {}

class ConcertFetchingSuccessFullState extends ConcertState {
  final List<ConcertDataModel> concerts;
  ConcertFetchingSuccessFullState({required this.concerts});
}

class ConcertByIdSuccessState extends ConcertState {
  final ConcertDataModel concert;
  ConcertByIdSuccessState({required this.concert});
}

class ConcertCreatedSuccessState extends ConcertState {
  final ConcertDataModel concert;
  ConcertCreatedSuccessState({required this.concert});
}

class ConcertUpdatedSuccessState extends ConcertState {
  final ConcertDataModel concert;
  ConcertUpdatedSuccessState({required this.concert});
}

class ConcertDeletedSuccessState extends ConcertState {
  final int concertId;
  ConcertDeletedSuccessState({required this.concertId});
}

class AttendeeAddedSuccessState extends ConcertState {}

class AttendeeRemovedSuccessState extends ConcertState {}

class ConcertsErrorState extends ConcertState {
  final String message;
  ConcertsErrorState({required this.message});
}
