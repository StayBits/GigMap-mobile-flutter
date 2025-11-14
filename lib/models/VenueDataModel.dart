class VenueDataModel {
  String name;
  String address;
  double latitude;
  double longitude;
  int capacity;

  VenueDataModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.capacity,
  });

  static VenueDataModel objJson(Map<String, dynamic> json) {
    return VenueDataModel(
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'] as int,
    );
  }
}