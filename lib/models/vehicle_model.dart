class VehicleModel {
  String id;
  String plateNumber;
  String modelName;
  String status; // 'Active', 'Maintenance', 'Out of Service'
  DateTime? insuranceExpiry;
  DateTime? pucExpiry;

  VehicleModel({
    required this.id,
    required this.plateNumber,
    required this.modelName,
    required this.status,
    this.insuranceExpiry,
    this.pucExpiry,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'modelName': modelName,
      'status': status,
      'insuranceExpiry': insuranceExpiry?.toIso8601String(),
      'pucExpiry': pucExpiry?.toIso8601String(),
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map, String id) {
    return VehicleModel(
      id: id,
      plateNumber: map['plateNumber'] ?? '',
      modelName: map['modelName'] ?? '',
      status: map['status'] ?? 'Active',
      insuranceExpiry: map['insuranceExpiry'] != null
          ? DateTime.tryParse(map['insuranceExpiry'])
          : null,
      pucExpiry: map['pucExpiry'] != null
          ? DateTime.tryParse(map['pucExpiry'])
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
