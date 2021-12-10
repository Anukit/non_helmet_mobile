import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:non_helmet_mobile/models/data_image.dart';
import 'package:non_helmet_mobile/models/position_image.dart';
import 'package:non_helmet_mobile/pages/capture_detection/camera_utility.dart';
import 'package:non_helmet_mobile/utility/utility.dart';

// Future<void> convertImage(image, type) async {
//   print("convertImage");
//   Uint8List? bytes;
//   try {
//     if (type == "Video") {
//       imglib.Image img;
//       List imageLists = [];
//       if (image[0].format.group == ImageFormatGroup.yuv420) {
//         for (var i = 0; i < image.length; i++) {
//           imageLists.add(await convertYUV420toImageColor(image[i]));
//         }

//         final imglib.JpegDecoder decoder = imglib.JpegDecoder();
//         final List<imglib.Image> images = [];

//         for (var imgFile in imageLists) {
//           images.add(decoder.decodeImage(imgFile));
//         }

//         generateGIF(images);
//       } else if (image[0].format.group == ImageFormatGroup.bgra8888) {
//         img = _convertBGRA8888(image);
//         imglib.PngEncoder pngEncoder = imglib.PngEncoder();
//         bytes = pngEncoder.encodeImage(img) as Uint8List?;
//       }
//     } else if (type == "Image") {
//       imglib.Image img;

//       if (image.format.group == ImageFormatGroup.yuv420) {
//         bytes = await convertYUV420toImageColor(image);
//         if (bytes!.isNotEmpty) {
//           await saveImageDetect(bytes);
//         }
//       } else if (image.format.group == ImageFormatGroup.bgra8888) {
//         img = _convertBGRA8888(image);
//         imglib.PngEncoder pngEncoder = imglib.PngEncoder();
//         bytes = pngEncoder.encodeImage(img) as Uint8List?;
//       }
//     } else {
//       print("Error!!!: Invalid type");
//     }
//   } catch (e) {
//     print(">>>>>>>>>>>> ERROR:" + e.toString());
//   }
// }

// List<int>? generateGIF(Iterable<imglib.Image> images) {
//   print("generateGIF");
//   final imglib.Animation animation = imglib.Animation();
//   for (imglib.Image image in images) {
//     animation.addFrame(image);
//   }

//   saveVideo(imglib.encodeGifAnimation(animation));

//   return imglib.encodeGifAnimation(animation);
// }

// imglib.Image _convertBGRA8888(CameraImage image) {
//   return imglib.Image.fromBytes(
//     image.width,
//     image.height,
//     image.planes[0].bytes,
//     format: imglib.Format.bgra,
//   );
// }

// Future<Uint8List?> convertYUV420toImageColor(CameraImage image) async {
//   try {
//     final int width = image.width;
//     final int height = image.height;
//     final int uvRowStride = image.planes[1].bytesPerRow;
//     final int? uvPixelStride = image.planes[1].bytesPerPixel;
//     print("uvRowStride: " + uvRowStride.toString());
//     print("uvPixelStride: " + uvPixelStride.toString());
//     var img = imglib.Image(width, height); // Create Image buffer
//     // Fill image buffer with plane[0] from YUV420_888
//     for (int x = 0; x < width; x++) {
//       for (int y = 0; y < height; y++) {
//         final int uvIndex =
//             uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
//         final int index = y * width + x;
//         final yp = image.planes[0].bytes[index];
//         final up = image.planes[1].bytes[uvIndex];
//         final vp = image.planes[2].bytes[uvIndex];
//         int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
//         int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
//             .round()
//             .clamp(0, 255);
//         int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
//         img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
//       }
//     }
//     imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
//     List<int> png = pngEncoder.encodeImage(img);
//     final originalImage = imglib.decodeImage(png);
//     final height1 = originalImage!.height;
//     final width1 = originalImage.width;
//     late imglib.Image fixedImage;
//     if (height1 < width1) {
//       fixedImage = imglib.copyRotate(originalImage, 90);
//     }
//     return imglib.encodeJpg(fixedImage) as Uint8List?;
//   } catch (e) {
//     print(">>>>>>>>>>>> ERROR:" + e.toString());
//   }
//   return null;
// }

//แปลงรูปภาพพร้อม Crop
List<ListResultImage> convertImage(listdata) {
  print("convertImage");
  CameraImage image = listdata[0]; //ไฟล์รูปจาก CameraImage
  List aaa = [];
  List bbb = [];
  int width = image.width;
  int height = image.height;
  int uvRowStride = image.planes[1].bytesPerRow;
  int? uvPixelStride = image.planes[1].bytesPerPixel;
  List<int> listAvaColors = listdata[3]; //ลิสสำหรับเก็บค่าเฉลี่ยสี
  List<Uint8List> listFileImage = []; //ลิสเก็บไฟล์รูปภาพ
  List<ListResultImage> listresult = []; //ลิสคำตอบที่จะรีเทิร์นกลับ

  var img = imglib.Image(width, height); // Create Image buffer
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int uvIndex =
          uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
      int index = y * width + x;
      aaa.add(index);
      bbb.add(uvIndex);
    }
  }
  /* for (var i = 0; i < a.length; i++) { */
  for (var i = 0; i < bbb.length; i++) {
    var yp = image.planes[0].bytes[aaa[i]];
    var up = image.planes[1].bytes[bbb[i]];
    var vp = image.planes[2].bytes[bbb[i]];
    int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
    int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
        .round()
        .clamp(0, 255);
    int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
    img.data[aaa[i]] = (0xFF << 24) | (b << 16) | (g << 8) | r;
  }
  /*  } */

  imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
  List<int> png = pngEncoder.encodeImage(img);
  final originalImage = imglib.decodeImage(png);
  final height1 = originalImage!.height;
  final width1 = originalImage.width;
  late imglib.Image fixedImage;
  if (height1 < width1) {
    fixedImage = imglib.copyRotate(originalImage, 90);
  }
  /////////////////////////////////////////////////////////////////////
  List<PositionImage> listCoor =
      imagePosition(listdata); //รับตำแหน่งภาพที่ได้จากการตรวจจับ
  if (listCoor.isNotEmpty) {
    for (var i = 0; i < listCoor.length; i++) {
      //ฟังก์ชัน Crop รูป
      imglib.Image destImage = imglib.copyCrop(
          //รูปที่ผ่านการ Crop แล้ว
          fixedImage, //ไฟล์รูปที่ได้จากการแปลง
          listCoor[i].x.round() + 100, //ค่า x
          listCoor[i].y.round(), //ค่า y
          listCoor[i].w.round() + 200, //ค่า w
          height); //ค่า h
      var fileImage =
          imglib.encodeJpg(destImage) as Uint8List?; //ไฟล์ภาพที่ได้ Crop แล้ว
      Color averageColor = getAverageColor(fileImage!); //รับค่าสี
      listAvaColors.add(averageColor.value);
      listFileImage.add(fileImage);
    }
    listresult.add(ListResultImage(listFileImage, listAvaColors));
    return listresult;
  } else {
    return [];
  }
  // if (listCoor.isNotEmpty && listCoor[0] != null) {
  //   //ฟังก์ชัน Crop รูป
  //   imglib.Image destImage = imglib.copyCrop(
  //       //รูปที่ผ่านการ Crop แล้ว
  //       fixedImage, //ไฟล์รูปที่ได้จากการแปลง
  //       listCoor[0].round() + 200, //ค่า x
  //       listCoor[1].round(), //ค่า y
  //       listCoor[2].round(), //ค่า w
  //       height); //ค่า h
  //   var result = imglib.encodeJpg(destImage) as Uint8List?;
  //   Color averageColor = getAverageColor(result!); //รับค่าสี
  //   listAvaColors.add(averageColor.value);
  //   listresult.add(result);
  //   listresult.add(listAvaColors);
  //   return listresult;
  // } else {
  //   return [];
  // }
  /////////////////////////////////////////////////////////////////////
}
