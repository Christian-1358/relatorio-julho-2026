class ClimateSettings {
  final bool isOn;
  final int temperature; // Celsius (16-30)
  final int fanSpeed; // 0-7
  final bool isRecirculating;
  final String mode; // cooling, heating, auto, defrost
  final bool preClimateEnabled;
  final int preClimateTime; // minutes

  ClimateSettings({
    this.isOn = false,
    this.temperature = 22,
    this.fanSpeed = 3,
    this.isRecirculating = false,
    this.mode = 'auto',
    this.preClimateEnabled = false,
    this.preClimateTime = 15,
  });

  ClimateSettings copyWith({
    bool? isOn,
    int? temperature,
    int? fanSpeed,
    bool? isRecirculating,
    String? mode,
    bool? preClimateEnabled,
    int? preClimateTime,
  }) {
    return ClimateSettings(
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      isRecirculating: isRecirculating ?? this.isRecirculating,
      mode: mode ?? this.mode,
      preClimateEnabled: preClimateEnabled ?? this.preClimateEnabled,
      preClimateTime: preClimateTime ?? this.preClimateTime,
    );
  }
}
