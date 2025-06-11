class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: map['created_at'],
    );
  }
}

class LocationModel {
  final int? id;
  final int userId;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final String? notes;
  final String? createdAt;

  LocationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }
}