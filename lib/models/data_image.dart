import 'dart:typed_data';
import 'dart:ui';

import 'package:non_helmet_mobile/models/model_tflite.dart';

//ข้อมูลของรูปภาพ
class DataImage {
  var fileImage;
  var dateCreate;
  var latitude;
  var longitude;

  DataImage(this.fileImage, this.dateCreate, this.latitude, this.longitude);
}

//ลิสไฟล์รูปภาพ และค่าเฉลี่ยสีที่ได้จากการตรวจจับแล้ว
class ListResultImage {
  List<DataDetectedImage> dataImage; //ลิสรูปภาพที่ได้จากการตรวจจับ
  List<DataAveColor> listAvgColor; //ลิสค่าเฉลี่ยสีของรูปภาพ
  List<dynamic> dataforTrack;

  ListResultImage(this.dataImage, this.listAvgColor, this.dataforTrack);
}

class DataDetectedImage {
  Uint8List riderImg;
  Uint8List license_plateImg;
  DataDetectedImage(this.riderImg, this.license_plateImg);
}

class DataAveColor {
  int id;
  Color avgColor;
  DataAveColor(this.id, this.avgColor);
}
