class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String nic;
  final String? provider;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.nic,
    this.provider,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'nic': nic,
      'provider': provider ?? 'email',
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      nic: map['nic'] ?? '',
      provider: map['provider'],
    );
  }
}
