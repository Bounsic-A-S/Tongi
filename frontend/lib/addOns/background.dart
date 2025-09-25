import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Android
const String notificationChannelId = 'tongi_service_channel';
final FlutterLocalNotificationsPlugin fluterLocalNotiPlug =
    FlutterLocalNotificationsPlugin();
Future<void> initNoti() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      fluterLocalNotiPlug
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (androidImplementation != null) {
    await androidImplementation.requestNotificationsPermission();
  }

  const AndroidInitializationSettings intiSettingsAndroid =
      AndroidInitializationSettings('mipmap/ic_launcher');
  const DarwinInitializationSettings initSettingsIOS =
      DarwinInitializationSettings();

  const InitializationSettings initSetting = InitializationSettings(
    android: intiSettingsAndroid,
    iOS: initSettingsIOS,
  );

  await fluterLocalNotiPlug.initialize(initSetting);
}

Future<void> showNoti() async {
  const AndroidNotificationDetails androidNotiDetail =
      AndroidNotificationDetails(
        notificationChannelId, // Use the same channel ID
        'Foreground Service',
        channelDescription: 'Notification for the background service',
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true,
      );

  const NotificationDetails notiDetails = NotificationDetails(
    android: androidNotiDetail,
  );

  await fluterLocalNotiPlug.show(
    1,
    'Uso Segundo Plano',
    'Se ha comenzado a escuchar en el Segundo plano',
    notiDetails,
  );
}
void updateNotificationText(String title, String text) {
  FlutterForegroundTask.updateService(
    notificationTitle: title,
    notificationText: text,
  );
}


void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: notificationChannelId,
      channelName: 'Foreground Service Notification',
      channelDescription: 'Mantiene la app en segundo plano',
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000), // ✅ solo el valor
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

void stopForegroundTask() {
  FlutterForegroundTask.stopService();
}

Future<bool> startForegroundTask() async {
  if (!await FlutterForegroundTask.canDrawOverlays) {
    FlutterForegroundTask.openSystemAlertWindowSettings();
    return false; // Return false if permission is denied
  }

  await showNoti();

  final ServiceRequestResult result = await FlutterForegroundTask.startService(
    notificationTitle: "Modo escucha en segundo plano",
    notificationText: "La app está escuchándote",
    callback: startCallback,
  );

  // Return true if the service was successfully started, false otherwise.
  return result is ServiceRequestSuccess;
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Initial notification is handled by startForegroundTask
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    FlutterForegroundTask.updateService(
      notificationTitle: "Servicio activo",
      notificationText: "La app sigue funcionando",
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // You can update the notification here too
    FlutterForegroundTask.updateService(
      notificationTitle: "Servicio detenido",
      notificationText: "La app ha dejado de escuchar",
    );
  }

}
