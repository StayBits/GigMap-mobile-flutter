import 'package:flutter/material.dart';
import 'package:gigmap_mobile_flutter/models/m1au/M1AUBotReply.dart';

class ConcertCardM1AU extends StatelessWidget {
  final M1AUConcertCard concert;
  final VoidCallback onNavigateToArtist;
  final VoidCallback onNavigateToConcert;

  const ConcertCardM1AU({
    Key? key,
    required this.concert,
    required this.onNavigateToArtist,
    required this.onNavigateToConcert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Stack(
        children: [
          // Imagen principal
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              concert.imageUrl ?? '',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note, size: 60, color: Colors.grey),
              ),
            ),
          ),

          // Gradient overlay
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.75),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),

          // Contenido
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge del artista
                  if (concert.artist?.username != null || concert.artist?.name != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            concert.artist?.username ?? concert.artist?.name ?? 'Artista',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Info del concierto
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        concert.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (concert.formattedDate != null) ...[
                            const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                concert.formattedDate!,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (concert.venue?.name != null) ...[
                            const Icon(Icons.place, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                concert.venue!.name!,
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Botones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onNavigateToArtist,
                              icon: const Icon(Icons.person, size: 16),
                              label: const Text('Artista', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.5)),
                                backgroundColor: Colors.white.withOpacity(0.2),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onNavigateToConcert,
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Ver más', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C0F1A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}