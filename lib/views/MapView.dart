import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../bloc/concerts/ConcertsBloc.dart';
import '../components/GigmapBottomBar.dart';
import '../models/ConcertDataModel.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final ConcertsBloc concertsBloc = ConcertsBloc();
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  ConcertDataModel? selectedConcert;
  
  int _bottomIndex = 1; // Mapa seleccionado por defecto

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

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          zoom: 15,
        ),
      ),
    );
  }

  Set<Marker> _createMarkers(List<ConcertDataModel> concerts) {
    return concerts.map((concert) {
      return Marker(
        markerId: MarkerId(concert.id.toString()),
        position: LatLng(concert.venue.latitude, concert.venue.longitude),
        infoWindow: InfoWindow(
          title: concert.name,
          snippet: '${concert.venue.name} • ${formatConcertDate(concert.date)}',
        ),
        onTap: () => _onMarkerTapped(concert),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet,
        ),
      );
    }).toSet();
  }

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/concerts');
            }
          },
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
          
          // Navegación según el índice
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/concerts');
          } else if (index == 2) {
            // TODO: Navegar a creación de concierto
          } else if (index == 3) {
            // TODO: Navegar a configuración
          }
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
              markers = _createMarkers(successState.concerts);
              return _buildMap();
            default:
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5C0F1A),
                ),
              );
          }
        },
      ),

      // Card flotante con detalles del concierto seleccionado
      floatingActionButton: selectedConcert != null 
        ? Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: 120,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Imagen del concierto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        selectedConcert!.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.music_note, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Información del concierto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedConcert!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedConcert!.venue.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatConcertDate(selectedConcert!.date),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5C0F1A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Botón de cerrar
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedConcert = null;
                        });
                      },
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: LatLng(-12.046374, -77.042793), // Lima, Perú por defecto
            zoom: 12,
          ),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
        ),
        
        // Overlay con texto "Descubre conciertos cerca de ti"
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Descubre conciertos cerca de ti',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C0F1A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
