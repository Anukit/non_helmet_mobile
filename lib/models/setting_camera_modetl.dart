class SettingCam {
  String resolution;
  String autoUpload;
  String recordVideo;
  String boundingBox;

  SettingCam(
      this.resolution, this.autoUpload, this.recordVideo, this.boundingBox);

  Map<String, dynamic> toJson() {
    return {
      'resolution': resolution,
      'autoUpload': autoUpload,
      'recordVideo': recordVideo,
      'boundingBox': boundingBox,
    };
  }
}
