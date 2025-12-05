import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/concerts/ConcertsBloc.dart';
import '../models/ConcertDataModel.dart';
import 'ConcertDetailView.dart';

class MapView extends StatefulWidget {
  final int? selectedConcertId;

  const MapView({super.key, this.selectedConcertId});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ConcertsBloc concertsBloc = ConcertsBloc();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  ConcertDataModel? selectedConcert;
  List<ConcertDataModel> concerts = [];
  final ScrollController _scrollController = ScrollController();
  bool _hasInitializedFromParam = false;

  @override
  void initState() {
    super.initState();
    concertsBloc.add(ConcertInitialFetchEvent());
  }

  @override
  void dispose() {
    concertsBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Si hay un concierto seleccionado esperando, moverlo ahora que el mapa está listo
    if (selectedConcert != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(selectedConcert!.venue.latitude, selectedConcert!.venue.longitude),
              zoom: 16,
            ),
          ),
        );
      });
    }
  }

  void _onMarkerTapped(ConcertDataModel concert) {
    setState(() {
      selectedConcert = concert;
    });

    // Mover cámara al marcador
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(concert.venue.latitude, concert.venue.longitude),
          zoom: 16,
        ),
      ),
    );
  }

  Set<Marker> _createMarkers(List<ConcertDataModel> concerts) {
    return concerts.map((concert) {
      return Marker(
        markerId: MarkerId(concert.id.toString()),
        position: LatLng(concert.venue.latitude, concert.venue.longitude),
        onTap: () => _onMarkerTapped(concert),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();
  }

  String formatConcertDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoDate.split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
            concerts = state.concerts;
            markers = _createMarkers(concerts);

            // Si hay un concierto seleccionado desde otra pantalla y no lo hemos inicializado
            if (widget.selectedConcertId != null && !_hasInitializedFromParam && concerts.isNotEmpty) {
              _hasInitializedFromParam = true;

              final concert = concerts.firstWhere(
                    (c) => c.id == widget.selectedConcertId,
                orElse: () => concerts.first,
              );

              // Seleccionar el concierto inmediatamente
              selectedConcert = concert;

              // Esperar a que el mapa esté creado y luego mover la cámara
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mapController != null && mounted) {
                    print('🗺️ Moviendo cámara a: ${concert.name}');
                    print('📍 Lat: ${concert.venue.latitude}, Lng: ${concert.venue.longitude}');

                    mapController!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(concert.venue.latitude, concert.venue.longitude),
                          zoom: 16,
                        ),
                      ),
                    );
                  }
                });
              });
            }

            return _buildContent();
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF5C0F1A),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // Título "Descubre conciertos cerca de ti"
        const Text(
          'Descubre conciertos cerca de ti',
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 14),

        // MAPA CON TAMAÑO FIJO
        Container(
          height: 600,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFFEFEFEF),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(-12.046374, -77.042793),
                  zoom: 13,
                ),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                onTap: (_) {
                  setState(() {
                    selectedConcert = null;
                  });
                },
              ),

              // InfoWindow personalizada cuando hay un concierto seleccionado
              if (selectedConcert != null)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: _buildInfoCard(selectedConcert!),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Título "Lista de conciertos cerca tuyo"
        const Text(
          'Lista de conciertos cerca tuyo',
          style: TextStyle(
            color: Color(0xFF5C0F1A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 12),

        // LISTA DE CONCIERTOS
        if (concerts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                color: Color(0xFF5C0F1A),
              ),
            ),
          )
        else
          ...concerts.asMap().entries.map((entry) {
            final index = entry.key;
            final concert = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSimpleConcertRow(concert, index),
            );
          }).toList(),

        // Espaciado final para que no lo tape la bottom bar
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildInfoCard(ConcertDataModel concert) {
    return GestureDetector(
        onTap: () {
          print('🎵 Card clickeado! Concert ID: ${concert.id}');
          print('🎵 Concert name: ${concert.name}');

          // Navegar a ConcertDetailView
          if (concert.id != null) {
            print(' Navegando a ConcertDetailView con ID: ${concert.id}');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: concertsBloc,
                  child: ConcertDetailView(concertId: concert.id!),
                ),
              ),
            );
          } else {
            print('Concert ID es null, no se puede navegar');
          }
        },
        child: Container(
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  concert.image,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.music_note, color: Colors.grey, size: 40),
                  ),
                ),
              ),

              // Contenido de texto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concert.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatConcertDate(concert.date)}, ${concert.venue.name}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
    }

  Widget _buildSimpleConcertRow(ConcertDataModel concert, int index) {
    final isSelected = selectedConcert?.id == concert.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedConcert = concert;
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(concert.venue.latitude, concert.venue.longitude),
              zoom: 16,
            ),
          ),
        );
      },
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                concert.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatConcertDate(concert.date)}, ${concert.venue.name}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}