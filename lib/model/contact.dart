class Contact {
  final int? id;
  final String phoneNumber;
  final String name;
  final String? birthday;
  final String? email;
  final String? address;
  final String? notes;

  Contact({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.birthday,
    this.email,
    this.address,
    this.notes,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'email': email,
      'address': address,
      'phoneNumber': phoneNumber,
      'notes': notes,
    };
  }

  Contact.fromDb(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        birthday = map['birthday'],
        email = map['email'],
        address = map['address'],
        phoneNumber = map['phoneNumber'],
        notes = map['notes']

  ;

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, birthday: $birthday, email: $email, address: $address, phoneNumber: $phoneNumber, notes : $notes}';
  }
}