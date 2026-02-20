class UserDTO {
  final String id;
  final bool verified;
  final String countryCode;
  final String cityCode;

  const UserDTO({
    required this.id,
    required this.verified,
    required this.countryCode,
    required this.cityCode,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'],
      verified: json['verified'],
      countryCode: json['country_code'],
      cityCode: json['city_code'],
    );
  }
}
