class AppUser {
  final String id;
  final String name;
  final String email;
  final String password; // για demo μόνο (ΟΧΙ για κανονική εφαρμογή)
  final String role; // "guest" ή "host"

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "password": password,
        "role": role,
      };

  static AppUser fromMap(Map<String, dynamic> map) => AppUser(
        id: map["id"],
        name: map["name"],
        email: map["email"],
        password: map["password"],
        role: map["role"],
      );
    
  // Keep toJson/fromJson proxies if needed, but prefer Map for DB
  Map<String, dynamic> toJson() => toMap();
  static AppUser fromJson(Map<String, dynamic> json) => fromMap(json);
}
