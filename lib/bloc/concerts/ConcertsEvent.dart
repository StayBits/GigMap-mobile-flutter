part of 'ConcertsBloc.dart';

abstract class ConcertsEvent {}

class ConcertInitialFetchEvent extends ConcertsEvent {}

class FetchConcertByIdEvent extends ConcertsEvent {
  final int concertId;
  FetchConcertByIdEvent(this.concertId);
}

class FetchConcertsByGenreEvent extends ConcertsEvent {
  final String genre;
  FetchConcertsByGenreEvent(this.genre);
}

class FetchConcertsByArtistEvent extends ConcertsEvent {
  final int artistId;
  FetchConcertsByArtistEvent(this.artistId);
}

class FetchConcertsByUserEvent extends ConcertsEvent {
  final int userId;
  FetchConcertsByUserEvent(this.userId);
}

class CreateConcertEvent extends ConcertsEvent {
  final Map<String, dynamic> data;
  CreateConcertEvent(this.data);
}

class UpdateConcertEvent extends ConcertsEvent {
  final int concertId;
  final Map<String, dynamic> data;
  UpdateConcertEvent(this.concertId, this.data);
}

class DeleteConcertEvent extends ConcertsEvent {
  final int concertId;
  DeleteConcertEvent(this.concertId);
}

class AddAttendeeEvent extends ConcertsEvent {
  final int concertId;
  final int userId;
  AddAttendeeEvent(this.concertId, this.userId);
}

class RemoveAttendeeEvent extends ConcertsEvent {
  final int concertId;
  final int userId;
  RemoveAttendeeEvent(this.concertId, this.userId);
}

class FetchAttendedConcertsByUserEvent extends ConcertsEvent {
  final int userId;
  FetchAttendedConcertsByUserEvent({required this.userId});
}
