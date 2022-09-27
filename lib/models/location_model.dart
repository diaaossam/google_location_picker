class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeId;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.address,
  });

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
    );
  }
}
