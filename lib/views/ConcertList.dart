import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/views/CreateConcertView.dart';
import 'package:gigmap_mobile_flutter/views/ConcertDetailView.dart';

import '../bloc/concerts/ConcertsBloc.dart';
import '../models/ConcertDataModel.dart';

class Concertlist extends StatefulWidget {
  const Concertlist({super.key});

  @override
  State<Concertlist> createState() => _ConcertlistState();
}

class _ConcertlistState extends State<Concertlist> {
  final ConcertsBloc concertsBloc = ConcertsBloc();

  final List<String> _genres = [
    'ROCK',
    'POP',
    'ELECTRONICA',
    'URBANO',
    'JAZZ',
    'INDIE',
    'CLASICO',
    'METAL',
    'FOLK',
    'COUNTRY',
    'REGGAE',
    'BLUES',
    'ALTERNATIVE',
    'PUNK',
    'SOUL',
    'FUNK',
    'R_AND_B',
    'LATIN',
    'WORLD',
    'HIP_HOP',
    'CLASSICAL',
    'ELECTRONIC',
    'OTHER'
  ];


  String formatConcertDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];

      return "${date.day} de ${months[date.month - 1]}";
    } catch (_) {
      return isoDate;
    }
  }

  @override
  void initState() {
    super.initState();
    concertsBloc.add(ConcertInitialFetchEvent());
  }

  @override
  void dispose() {
    concertsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF3F3F3),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5C0F1A)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'GigMap',
          style: TextStyle(
            color: Color(0xFF5C0F1A),
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

      body: BlocConsumer<ConcertsBloc, ConcertState>(
        bloc: concertsBloc,
        listenWhen: (previous, current) => current is ConcertActionState,
        buildWhen: (previous, current) => current is! ConcertActionState,
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ConcertFetchingSuccessFullState) {
            return _buildSuccessList(state.concerts);
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5C0F1A),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateConcertView()),
          );

          if (created == true) {
            concertsBloc.add(ConcertInitialFetchEvent());
          }
        },
        backgroundColor: const Color(0xFF5C0F1A),
        child: const Icon(Icons.add, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSuccessList(List<ConcertDataModel> concerts) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // FILTRO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF5C0F1A)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Filtrar por género',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5C0F1A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.tune, color: Color(0xFF5C0F1A)),
                ),
              ],
            ),
          ),

          // LISTA
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: concerts.length,
            itemBuilder: (_, index) => _buildConcertCard(concerts[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildConcertCard(ConcertDataModel concert) {
    return GestureDetector(
      onTap: () {
        if (concert.id != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: concertsBloc,
                child: ConcertDetailView(concertId: concert.id!),
              ),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  concert.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey.shade300),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concert.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatConcertDate(concert.date)}, '
                          '${concert.venue.name}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
