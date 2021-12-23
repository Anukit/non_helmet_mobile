import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:non_helmet_mobile/models/data_image.dart';
import 'package:non_helmet_mobile/models/model_tflite.dart';
import 'package:non_helmet_mobile/models/position_image.dart';
import 'package:non_helmet_mobile/utility/utility.dart';

///แปลงรูปภาพพร้อม Crop
List<ListResultImage> convertImage(listdata) {
  print("convertImage");
  ////////////////////////ตัวแปร////////////////////////////////////////
  CameraImage image = listdata[0]; //ไฟล์รูปจาก CameraImage
  List<dynamic>? recognitions = listdata[1]; //ข้อมูลที่ได้จากการตรวจจับ
  List<Color> listAvaColors = listdata[3]; //ลิสสำหรับเก็บค่าเฉลี่ยสี
  List<DataDetectedImage> listDataImage = []; //ลิสเก็บข้อมูลรูปภาพ
  List<ListResultImage> listresult = []; //ลิสคำตอบที่จะรีเทิร์นกลับ
  List<ModelTflite> recogNew = []; //ลิสค่า Recognition ใหม่
  /////////////////////////////////////////////////////////////////////
  print("listFileImage = $listAvaColors");
  //รูปกรณีมีมากกว่า 1 คันใน 1 ภาพ
  for (var i = 0; i < recognitions!.length; i++) {
    if (recognitions[i]["detectedClass"] == "Rider") {
      //recogNew.add(recognitions[i]);
      recogNew.add(ModelTflite(recognitions[i], null, null));
    }
  }

  //ตรวจสอบคลาส
  if (recogNew.isNotEmpty) {
    for (var i = 0; i < recogNew.length; i++) {
      // print("recogNew : ${recogNew[i]}");
      for (var y = 0; y < recognitions.length; y++) {
        if (recognitions[y]["detectedClass"] != "Rider") {
          double resultCheck = isObject(recogNew[i].rider, recognitions[y]);
          //print("resultCheck = $resultCheck");
          if (resultCheck > 0.02) {
            // print("recogNew : ${recogNew[i]}");
            // print("recognitions : ${recognitions[y]}");
            if (recognitions[y]["detectedClass"] == "None-helmet") {
              recogNew[i] = ModelTflite(recogNew[i].rider, recognitions[y],
                  recogNew[i].license_plate);
            } else if (recognitions[y]["detectedClass"] == "License-plate") {
              recogNew[i] = ModelTflite(
                  recogNew[i].rider, recogNew[i].helmet, recognitions[y]);
            }
          }
        }
      }
      // if (recogNew[i].helmet == null || recogNew[i].license_plate == null) {
      //   recogNew.removeAt(i);
      // } else {}
    }

    //ตรวจสอบให้เหลือคลาสที่จะนำไปใช้
    if (recogNew.isNotEmpty) {
      for (var i = 0; i < recogNew.length; i++) {
        if (recogNew[i].helmet == null || recogNew[i].license_plate == null) {
          recogNew.removeAt(i);
        } else {}
      }
    } else {
      return [];
    }
    // print("recogNew = $recogNew");
    // print("recogNew = ${recogNew.length}");
    // print("rider = ${recogNew.first.rider}");
    // print("helmet = ${recogNew.first.helmet}");
    // print("license_plate = ${recogNew.first.license_plate}");

    if (recogNew.isNotEmpty) {
      //แปลง image stream to image
      imglib.Image fixedImage = yuv420toImageColor(image);

      for (var i = 0; i < recogNew.length; i++) {
        //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class Rider
        PositionImage coorRider = imagePosition(listdata, recogNew[i].rider);

        //ฟังก์ชัน Crop รูป Class Rider
        imglib.Image destImage = copyCropp(
            fixedImage, //ไฟล์รูปที่ได้จากการแปลง
            coorRider.x.round(), //ค่า x
            coorRider.y.round(), //ค่า y
            min(coorRider.w.round(),
                fixedImage.width - coorRider.x.round()), //ค่า w
            min(coorRider.h.round(),
                fixedImage.height - coorRider.y.round())); //ค่า h
        //ไฟล์ภาพที่ได้ Crop แล้ว
        var riderImage = imglib.encodeJpg(destImage) as Uint8List?;
        //รับค่าสี
        Color averageColor = getAverageColor(riderImage!);
        //print("averageColor = ${averageColor}");
        print("listFileImage = $listAvaColors");
        if (listAvaColors.isNotEmpty) {
          //เปรียบเทียบค่าสี
          for (var i = 0; i < listAvaColors.length; i++) {
            int checkColorImg = compareColor(averageColor, listAvaColors[i]);
            print("checkColorImg = $checkColorImg");
            // 90 = เปอร์เซ็นการ Macth ของสี
            if (checkColorImg > 90) {
              riderImage = null;
            }
          }
        }
        if (riderImage != null) {
          //รับตำแหน่งภาพที่ได้จากการตรวจจับ Class License
          PositionImage coorlicenseP =
              imagePosition(listdata, recogNew[i].license_plate);

          //ฟังก์ชัน Crop รูป Class license plate
          imglib.Image destImages = copyCropp(
              fixedImage, //ไฟล์รูปที่ได้จากการแปลง
              coorlicenseP.x.round(), //ค่า x
              coorlicenseP.y.round(), //ค่า y
              min(coorlicenseP.w.round(),
                  fixedImage.width - coorlicenseP.x.round()), //ค่า w
              min(coorlicenseP.h.round(),
                  fixedImage.height - coorlicenseP.y.round())); //ค่า h

          var licensePlateImg = imglib.encodeJpg(destImages) as Uint8List?;

          listDataImage.add(DataDetectedImage(riderImage, licensePlateImg!));
          listAvaColors.add(averageColor);
        }
      }
      // print("listFileImage = ${listFileImage}");
      // print("listFileImage = ${listAvaColors}");
      if (listDataImage.isNotEmpty) {
        listresult.add(ListResultImage(listDataImage, listAvaColors));
        return listresult;
      } else {
        return [];
      }
    } else {
      return [];
    }
  } else {
    return [];
  }
}

///แปลง Image Stream ในรูป yuv420 เป็นรูปภาพ
imglib.Image yuv420toImageColor(CameraImage image) {
  print("yuv420toImageColor");
  List listindex = [];
  List listuvIndex = [];
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
  /* for (var i = 0; i < a.length; i++) { */
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
  return fixedImage;
}
