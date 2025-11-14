import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gigmap_mobile_flutter/views/CreateConcertView.dart';
import '../bloc/concerts/ConcertsBloc.dart';
import '../components/GigmapBottomBar.dart';
import '../models/ConcertDataModel.dart';

class Concertlist extends StatefulWidget {
  const Concertlist({super.key});

  @override
  State<Concertlist> createState() => _ConcertlistState();
}

class _ConcertlistState extends State<Concertlist> {
  final ConcertsBloc concertsBloc = ConcertsBloc();

  //format date
  String formatConcertDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);

      final months = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];

      final day = date.day;
      final month = months[date.month - 1];

      return "$day de $month";
    } catch (_) {
      return isoDate;
    }
  }
  int _bottomIndex = 0;

  final List<IconData> _fabIcons = const [
    Icons.home,
    Icons.location_on_outlined,
    Icons.group_add_outlined,
    Icons.settings_outlined,
  ];

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

      bottomNavigationBar: GigmapBottomBar(
        currentIndex: _bottomIndex,
        onItemSelected: (index) {
          setState(() {
            _bottomIndex = index;
          });
        },
      ),

      body: BlocConsumer<ConcertsBloc, ConcertState>(
        bloc: concertsBloc,
        listenWhen: (previous, current) => current is ConcertActionState,
        buildWhen: (previous, current) => current is! ConcertActionState,
        listener: (context, state) {},
        builder: (context, state) {
          switch (state.runtimeType) {
            case ConcertFetchingSuccessFullState:
              final successState = state as ConcertFetchingSuccessFullState;
              return _buildSuccessList(successState.concerts);
            default:
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5C0F1A),
                ),
              );
          }
        },

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateConcertView(),
            ),
          );
        },
        backgroundColor: const Color(0xFF5C0F1A),

        child: const Icon(Icons.add, color: Colors.white,),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSuccessList(List<ConcertDataModel> concerts) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Fila filtros
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF5C0F1A)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(170, 0, 0, 0),
                      child: Text(
                        'Filtrar por género',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5C0F1A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

          // lista conciertos
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: concerts.length,
            itemBuilder: (context, index) {
              final concert = concerts[index];
              return _buildConcertCard(concert);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConcertCard(ConcertDataModel concert) {
    return Padding(
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
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
                    '${formatConcertDate(concert.date)}, ${concert.venue.name}',
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
    );
  }
}
