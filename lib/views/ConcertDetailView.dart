import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/concerts/ConcertsBloc.dart';
import '../models/ConcertDataModel.dart';
import '../models/UserDataModel.dart';
import '../repository/UserRepository.dart';

class ConcertDetailView extends StatefulWidget {
  final int concertId;

  const ConcertDetailView({super.key, required this.concertId});

  @override
  State<ConcertDetailView> createState() => _ConcertDetailViewState();
}

class _ConcertDetailViewState extends State<ConcertDetailView> {
  final Color wine = const Color(0xFF5C0F1A);

  bool isConfirmed = false;

  List<UserDataModel> allUsers = [];
  List<UserDataModel> confirmedUsers = [];

  @override
  void initState() {
    super.initState();

    context.read<ConcertsBloc>().add(FetchConcertByIdEvent(widget.concertId));


    _loadUsers();
  }

  Future<void> _loadUsers() async {
    allUsers = await UserRepository.fetchUsers();
    setState(() {});
  }

  List<UserDataModel> _matchUsers(ConcertDataModel concert) {
    return allUsers.where((u) => concert.attendees.contains(u.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: wine),
          onPressed: () {
            Navigator.pop(context);

            context.read<ConcertsBloc>().add(ConcertInitialFetchEvent());
          },
        ),
        centerTitle: true,
        title: Text('GigMap',
            style: TextStyle(
              color: wine,
              fontWeight: FontWeight.bold,
            )),
      ),

      body: BlocBuilder<ConcertsBloc, ConcertState>(
        builder: (context, state) {
          if (state is ConcertByIdSuccessState) {
            final concert = state.concert;


            isConfirmed = concert.attendees.contains(1);

            confirmedUsers = _matchUsers(concert);

            return _buildDetail(concert);
          }

          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF5C0F1A)));
        },
      ),
    );
  }


  Widget _buildDetail(ConcertDataModel concert) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerImage(concert),
          _infoCard(concert),
          _buttons(concert),
          const SizedBox(height: 16),
          _confirmedUsersSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _headerImage(ConcertDataModel concert) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          concert.image,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _infoCard(ConcertDataModel concert) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(concert.name,
                  style: TextStyle(
                    color: wine,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.location_on, size: 18, color: wine),
                const SizedBox(width: 6),
                Text(concert.venue.name,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
              ]),
              Row(children: [
                Icon(Icons.calendar_today, size: 18, color: wine),
                const SizedBox(width: 6),
                Text(
                  concert.date.split("T").first.replaceAll("-", " de "),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ]),
              const SizedBox(height: 12),
              Text(
                concert.description,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buttons(ConcertDataModel concert) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: ElevatedButton(
                onPressed: () => _toggleAttendance(concert.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  !isConfirmed ? wine : const Color(0xFF2C2C2C),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  !isConfirmed ? "Confirmar asistencia" : "Cancelar confirmación",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                ),
              )),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Tickets",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              )),
        ],
      ),
    );
  }


  Widget _confirmedUsersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Usuarios que confirmaron su asistencia",
            style: TextStyle(
              color: wine,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        const SizedBox(height: 12),

        confirmedUsers.isEmpty
            ? Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text("No hay usuarios confirmados aún",
                style: TextStyle(color: Colors.grey[700])),
          ),
        )
            : Column(
          children: confirmedUsers
              .map(
                (user) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        user.image ??
                            "",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name ?? "Sin nombre",
                            style: TextStyle(
                                color: wine,
                                fontWeight: FontWeight.bold)),
                        Text("@${user.username}",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
              .toList(),
        ),
      ]),
    );
  }


  void _toggleAttendance(int concertId) {
    setState(() => isConfirmed = !isConfirmed);

    if (isConfirmed) {
      context.read<ConcertsBloc>().add(AddAttendeeEvent(concertId, 1));
    } else {
      context.read<ConcertsBloc>().add(RemoveAttendeeEvent(concertId, 1));
    }
  }
}
