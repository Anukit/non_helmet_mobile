import 'dart:typed_data';
import 'dart:ui';

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
  List<Uint8List> fileImage; //ลิสรูปภาพที่ได้จากการตรวจจับ
  List<Color> averageColor; //ลิสค่าเฉลี่ยสีของรูปภาพ

  ListResultImage(this.fileImage, this.averageColor);
}
