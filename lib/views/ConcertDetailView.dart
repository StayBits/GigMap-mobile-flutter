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

  String formatConcertDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return "${date.day.toString().padLeft(2, '0')} de ${months[date.month - 1]} ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          'GigMap',
          style: TextStyle(
            color: wine,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Color(0xFF5C0F1A)),
          ),
        ],
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(concert),
            const SizedBox(height: 20),
            _descriptionSection(concert),
            const SizedBox(height: 20),
            _buttons(concert),
            const SizedBox(height: 24),
            _confirmedUsersSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _headerCard(ConcertDataModel concert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // imagen
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            concert.image,
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 280,
              color: Colors.grey.shade300,
              child: const Icon(Icons.music_note, size: 60, color: Colors.grey),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Nombre del concierto Y botón Ver en Mapa
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                concert.name,
                style: TextStyle(
                  color: wine,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            // Botón Ver en Mapa más compacto
            ElevatedButton.icon(
              onPressed: () {
                // Navegar al mapa con el concierto seleccionado
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (route) => false,
                  arguments: {
                    'initialIndex': 1,
                    'selectedConcertId': concert.id,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: wine,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.map,
                color: Colors.white,
                size: 14,
              ),
              label: const Text(
                'Ver en Mapa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Ubicación
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: wine,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                concert.venue.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Fecha
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: wine,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              formatConcertDate(concert.date),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _descriptionSection(ConcertDataModel concert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: TextStyle(
            color: wine,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          concert.description,
          style: const TextStyle(
            fontSize: 13,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buttons(ConcertDataModel concert) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _toggleAttendance(concert.id!),
            style: ElevatedButton.styleFrom(
              backgroundColor: !isConfirmed ? wine : Colors.white,
              foregroundColor: !isConfirmed ? Colors.white : wine,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: wine,
                  width: !isConfirmed ? 0 : 1.5,
                ),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check,
                  size: 16,
                  color: !isConfirmed ? Colors.white : wine,
                ),
                const SizedBox(width: 6),
                Text(
                  "Asistencia confirmada",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: !isConfirmed ? Colors.white : wine,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.confirmation_number,
                  size: 16,
                  color: Colors.white,
                ),
                SizedBox(width: 6),
                Text(
                  "Tickets",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _confirmedUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Usuarios que confirmaron su asistencia",
          style: TextStyle(
            color: wine,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        confirmedUsers.isEmpty
            ? Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "No hay usuarios confirmados aún",
            style: TextStyle(color: Colors.grey[700]),
          ),
        )
            : Column(
          children: confirmedUsers
              .map(
                (user) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(user.image ?? ""),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? "Sin nombre",
                        style: TextStyle(
                          color: wine,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "@${user.username}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
      ],
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