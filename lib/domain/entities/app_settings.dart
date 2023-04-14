class AppSettings{
  String saveDir;
  int simultaneousDownloads;
  bool onlyWiFi;
  bool onlySendFinishNotification;

//<editor-fold desc="Data Methods">

  AppSettings({
    required this.saveDir,
    required this.simultaneousDownloads,
    required this.onlyWiFi,
    required this.onlySendFinishNotification,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettings &&
          runtimeType == other.runtimeType &&
          saveDir == other.saveDir &&
          simultaneousDownloads == other.simultaneousDownloads &&
          onlyWiFi == other.onlyWiFi &&
          onlySendFinishNotification ==
              other.onlySendFinishNotification);

  @override
  int get hashCode =>
      saveDir.hashCode ^
      simultaneousDownloads.hashCode ^
      onlyWiFi.hashCode ^
      onlySendFinishNotification.hashCode;

  @override
  String toString() {
    return 'AppSettings{' +
        ' folderForFiles: $saveDir,' +
        ' simultaneousDownloads: $simultaneousDownloads,' +
        ' onlyWiFi: $onlyWiFi,' +
        ' sendNotificationOnlyWhenFinished: $onlySendFinishNotification,' +
        '}';
  }

  AppSettings copyWith({
    String? folderForFiles,
    int? simultaneousDownloads,
    bool? onlyWiFi,
    bool? sendNotificationOnlyWhenFinished,
  }) {
    return AppSettings(
      saveDir: folderForFiles ?? this.saveDir,
      simultaneousDownloads:
          simultaneousDownloads ?? this.simultaneousDownloads,
      onlyWiFi: onlyWiFi ?? this.onlyWiFi,
      onlySendFinishNotification: sendNotificationOnlyWhenFinished ??
          this.onlySendFinishNotification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'folderForFiles': this.saveDir,
      'simultaneousDownloads': this.simultaneousDownloads,
      'onlyWiFi': this.onlyWiFi,
      'sendNotificationOnlyWhenFinished': this.onlySendFinishNotification,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      saveDir: map['folderForFiles'] as String,
      simultaneousDownloads: map['simultaneousDownloads'] as int,
      onlyWiFi: map['onlyWiFi'] as bool,
      onlySendFinishNotification:
          map['sendNotificationOnlyWhenFinished'] as bool,
    );
  }

//</editor-fold>
}