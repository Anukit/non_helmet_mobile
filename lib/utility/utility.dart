import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lo;

String formatDate(dateTime) {
  var date = DateTime.parse(dateTime);
  String formattedDate = DateFormat('dd-MM-yyyy เวลา kk:mm').format(date);
  return formattedDate;
}

Future<bool> permissionCamera() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
  }

// You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.location,
    Permission.microphone,
    Permission.storage,
  ].request();

  if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.camera] == PermissionStatus.denied ||
      statuses[Permission.location] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.location] == PermissionStatus.denied ||
      statuses[Permission.microphone] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.microphone] == PermissionStatus.denied ||
      statuses[Permission.storage] == PermissionStatus.permanentlyDenied ||
      statuses[Permission.storage] == PermissionStatus.denied) {
    return false;
  } else {
    return true;
  }
}

Future<bool> checkGPS() async {
  lo.Location location = lo.Location();

  bool _serviceEnabled;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return false;
    } else {
      return true;
    }
  } else {
    return true;
  }
}

Future<Directory> checkDirectory(String folderName) async {
  final dir =
      Directory((await getExternalStorageDirectory())!.path + '/$folderName');

  if ((await dir.exists())) {
    return dir;
  } else {
    dir.create();
    return dir;
  }
}
