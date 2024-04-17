class PrinterConfig {
  final String name;
  final String ipAddress;

  PrinterConfig({required this.name, required this.ipAddress});

  Map<String, String> toMap() {
    return {'name': name, 'ipAddress': ipAddress};
  }

  factory PrinterConfig.fromMap(Map map) {
    return PrinterConfig(
      name: map['name'],
      ipAddress: map['ipAddress'],
    );
  }
}