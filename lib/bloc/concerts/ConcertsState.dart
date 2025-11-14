part of 'ConcertsBloc.dart';

abstract class ConcertState {}

abstract class ConcertActionState extends ConcertState {}

class ConcertsInitial extends ConcertState {}

class ConcertFetchingSuccessFullState extends ConcertState {
  final List<ConcertDataModel> concerts;

  ConcertFetchingSuccessFullState({
    required this.concerts,
  });
}