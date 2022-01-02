import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart' as dd;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as imglib;

Future<void> saveImageDetect(Uint8List riderImg, Uint8List licenseImg) async {
  print("saveImageDetect");
  //รับพิกัด
  var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  final exif = dd.FlutterExif.fromBytes(riderImg);
  await exif.setLatLong(position.latitude, position.longitude);
  await exif.setAttribute("DateTimeOriginal", DateTime.now().toString());
  await exif.saveAttributes();

  final modifiedImage = await exif.imageData;
  /////////////////////////////////////////////////////////////////////
  String tempPathPic = await createFolder("Pictures");
  String tempPathLic = await createFolder("License_plate");

  if (tempPathPic.isNotEmpty && tempPathLic.isNotEmpty) {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    var filePathRider = tempPathPic + '/file_$filename.jpg';
    var filePathLicense = tempPathLic + '/file_$filename.jpg';

    File(filePathRider).writeAsBytes(modifiedImage!);
    File(filePathLicense).writeAsBytes(licenseImg);
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
          result = await _flutterFFmpeg
              .execute("-f gif -i $inputFile -pix_fmt yuv420p $outputFile"),
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

class SaveVideo {
  List<CameraImage> listimg;
  String frameImgDirPath;
  String videoDirPath;
  ValueChanged<bool> callback;
  SaveVideo(
      this.listimg, this.frameImgDirPath, this.videoDirPath, this.callback);
  final worker = Worker();

  Future<void> init() async {
    await worker.init(
      mainMessageHandler,
      isolateMessageHandler,
      errorHandler: print,
    );
    worker.sendMessage({
      "listimg": listimg,
      "frameImgDirPath": frameImgDirPath,
      "videoDirPath": videoDirPath
    });
  }

  /// Handle the messages coming from the isolate
  void mainMessageHandler(dynamic data, SendPort isolateSendPort) async {
    print("SASSSSSSSSSSSSSSSSSSSSSSAS = $data");
    String _frameImgDirPath = data["frameImgDirPath"];
    String _videoDirPath = data["videoDirPath"];
    List<FileSystemEntity> _photoList = data["photoList"];
    final FlutterFFmpeg _flutterFFmpeg =
        FlutterFFmpeg(); // Create new ffmpeg instance somewhere in your code
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    String filePathMP4 = _videoDirPath + '/$filename.mp4';
    int result = await _flutterFFmpeg.execute(
        "-framerate 4 -probesize 42M -i $_frameImgDirPath/img%d.jpg -preset ultrafast -pix_fmt yuv420p $filePathMP4");
    if (result == 0) {
      print("True");
      // for (var i = 0; i < _photoList.length; i++) {
      //   File files = File(_frameImgDirPath + "/img${i + 1}.jpg");
      //   files.delete();
      // }
      final dir = Directory(_frameImgDirPath);
      dir.deleteSync(recursive: true);
      createFolder("FrameImage");
      callback(true);
    } else {
      print("False");
      callback(false);
    }
  }

  /// Handle the messages coming from the main
  static isolateMessageHandler(
      dynamic data, SendPort mainSendPort, SendErrorFunction sendError) async {
    List<CameraImage> listimg = data["listimg"];
    String frameImgDirPath = data["frameImgDirPath"];
    String videoDirPath = data["videoDirPath"];
    List<FileSystemEntity> photoList = [];
    print("data data listimg = ${listimg.length}");
    //แก้บัคเซฟวิดีโอ
    final File file = File('$frameImgDirPath/img.jpg');
    await file.writeAsString("Frame Image From CameraImage");

    for (var i = 0; i < listimg.length; i++) {
      List listindex = [];
      List listuvIndex = [];
      CameraImage image = listimg[i];
      int uvRowStride = image.planes[1].bytesPerRow;
      int? uvPixelStride = image.planes[1].bytesPerPixel;
      int width = image.width;
      int height = image.height;

      var img = imglib.Image(width, height); // Create Image buffer
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          int uvIndex =
              uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
          int index = y * width + x;
          listindex.add(index);
          listuvIndex.add(uvIndex);
        }
      }

      for (var i = 0; i < listuvIndex.length; i++) {
        var yp = image.planes[0].bytes[listindex[i]];
        var up = image.planes[1].bytes[listuvIndex[i]];
        var vp = image.planes[2].bytes[listuvIndex[i]];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img.data[listindex[i]] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }

      imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
      List<int> png = pngEncoder.encodeImage(img);
      final originalImage = imglib.decodeImage(png);
      final height1 = originalImage!.height;
      final width1 = originalImage.width;
      late imglib.Image fixedImage;
      if (height1 < width1) {
        fixedImage = imglib.copyRotate(originalImage, 90);
      }
      ////////////////////////////////////////////////////////////////////////
      photoList = Directory(frameImgDirPath).listSync();

      String filename = "";
      if (photoList.isNotEmpty && photoList.length > 1) {
        filename = (photoList.length).toString();
      } else {
        filename = 1.toString();
      }
      var filePath = "$frameImgDirPath/img$filename.jpg";
      print("CCCCCCCCCCCCCCCC = $filePath");
      File(filePath).writeAsBytes(imglib.encodeJpg(fixedImage) as Uint8List);
      ////////////////////////////////////////////////////////////////////////
    }
    mainSendPort.send({
      "frameImgDirPath": frameImgDirPath,
      "videoDirPath": videoDirPath,
      "photoList": photoList
    });
  }
}
