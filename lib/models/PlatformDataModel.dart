class PlatformDataModel {
  String platformName;
  String platformImage;

  PlatformDataModel({
    required this.platformName,
    required this.platformImage,
  });

  static PlatformDataModel objJson(Map<String, dynamic> json) {
    return PlatformDataModel(
      platformName: json['platformName'] as String,
      platformImage: json['platformImage'] as String,
    );
  }
}