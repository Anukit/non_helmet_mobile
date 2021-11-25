import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'package:non_helmet_mobile/utility/saveimage_video.dart';

Future<void> convertImage(image, type) async {
  print("convertImage");
  Uint8List? bytes;
  try {
    if (type == "Video") {
      imglib.Image img;
      List imageLists = [];
      if (image[0].format.group == ImageFormatGroup.yuv420) {
        for (var i = 0; i < image.length; i++) {
          imageLists.add(await convertYUV420toImageColor(image[i]));
        }

        final imglib.JpegDecoder decoder = imglib.JpegDecoder();
        final List<imglib.Image> images = [];

        for (var imgFile in imageLists) {
          images.add(decoder.decodeImage(imgFile));
        }

        generateGIF(images);
      } else if (image[0].format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
        imglib.PngEncoder pngEncoder = imglib.PngEncoder();
        bytes = pngEncoder.encodeImage(img) as Uint8List?;
      }
    } else if (type == "Image") {
      imglib.Image img;

      if (image.format.group == ImageFormatGroup.yuv420) {
        bytes = await convertYUV420toImageColor(image);
        if (bytes!.isNotEmpty) {
          await saveImageDetect(bytes);
        }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        img = _convertBGRA8888(image);
        imglib.PngEncoder pngEncoder = imglib.PngEncoder();
        bytes = pngEncoder.encodeImage(img) as Uint8List?;
      }
    } else {
      print("Error!!!: Invalid type");
    }
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
}

List<int>? generateGIF(Iterable<imglib.Image> images) {
  print("generateGIF");
  final imglib.Animation animation = imglib.Animation();
  for (imglib.Image image in images) {
    animation.addFrame(image);
  }

  saveVideo(imglib.encodeGifAnimation(animation));

  return imglib.encodeGifAnimation(animation);
}

imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    image.width,
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

Future<Uint8List?> convertYUV420toImageColor(CameraImage image) async {
  try {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;
    print("uvRowStride: " + uvRowStride.toString());
    print("uvPixelStride: " + uvPixelStride.toString());
    var img = imglib.Image(width, height); // Create Image buffer
    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
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
    return imglib.encodeJpg(fixedImage) as Uint8List?;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}
