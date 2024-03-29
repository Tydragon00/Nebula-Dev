class SmartwatchDeviceInfo {
  final String deviceName;
  final String uuid;
  final bool isConnected;
  final int batteryPercentage;

  SmartwatchDeviceInfo({
    required this.deviceName,
    required this.uuid,
    required this.isConnected,
    required this.batteryPercentage,
  });
}
