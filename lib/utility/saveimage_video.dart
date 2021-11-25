import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart' as dd;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveImageDetect(Uint8List bytes) async {
  print("saveImageDetect");
  //รับพิกัด
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  final exif = dd.FlutterExif.fromBytes(bytes);
  await exif.setLatLong(position.latitude, position.longitude);
  await exif.setAttribute("DateTimeOriginal", DateTime.now().toString());
  await exif.saveAttributes();

  final modifiedImage = await exif.imageData;
  /////////////////////////////////////////////////////////////////////
  String tempPath = await createFolder("Pictures");
  if (tempPath.isNotEmpty) {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    var filePath = tempPath + '/file_$filename.jpg';
    File(filePath).writeAsBytes(modifiedImage!);
  } else {}
  /////////////////////////////////////////////////////////////////////
}

Future<void> saveVideo(giffile) async {
  print("saveVideo");

  final FlutterFFmpeg _flutterFFmpeg =
      FlutterFFmpeg(); // Create new ffmpeg instance somewhere in your code
  int result;

  ////////////////////////////////////////////////////////////////////////////
  String tempPath = await createFolder("Video");
  if (tempPath.isNotEmpty) {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    String filePath = tempPath + '/file_$filename.gif';
    String filePathMP4 = tempPath + '/file_$filename.mp4';
    final String inputFile = filePath; //path of the gif file.
    final String outputFile = filePathMP4; //path to export the mp4 file.
    File(filePath).writeAsBytes(giffile!).then((gifData) async => {
          //แปลงไฟล์ gif => mp4
          result =
              await _flutterFFmpeg.execute("-f gif -i $inputFile $outputFile"),
          if (result == 0) {await gifData.delete(), print("Succeed")}
        });
  } else {}
  //////////////////////////////////////////////////////////////////////////////
}

Future<String> createFolder(String folderName) async {
  final dir =
      Directory((await getExternalStorageDirectory())!.path + '/$folderName');

  if ((await dir.exists())) {
    return dir.path;
  } else {
    dir.create();
    return dir.path;
  }
}
