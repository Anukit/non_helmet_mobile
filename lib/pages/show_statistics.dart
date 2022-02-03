import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/data_statics.dart';

class ShowStatPage extends StatefulWidget {
  DataStatics dataStat;
  ShowStatPage(this.dataStat, {Key? key}) : super(key: key);

  @override
  State<ShowStatPage> createState() => _ShowStatPageState();
}

class _ShowStatPageState extends State<ShowStatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'สถิติ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
              child: Center(
            child: Column(
              children: [
                const SizedBox(height: 2),
                ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) =>
                        displayStatics(index, widget.dataStat))
              ],
            ),
          )),
        ));
  }

  ///แสดงสถิติ (ส่วนหลัก)
  Widget displayStatics(int index, DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                index == 0
                    ? staticsNotUpload(data)
                    : index == 1
                        ? staticsRiderMe(data)
                        : staticsRiderAll(data),
              ],
            ))
      ],
    );
  }

  ///สถิติของผู้ใช้คนนั้น กรณียังไม่อัปโหลด
  Widget staticsNotUpload(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้ (ยังไม่อัปโหลด)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ทั้งหมด:',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
                margin: const EdgeInsets.all(20.0),
                height: 25.0,
                width: 80.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  // ignore: unnecessary_const
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Align(
                    alignment: Alignment.center,
                    child: Text(data.countRiderNotup.toString()))),
            const Text(
              'คัน',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///สถิติของผู้ใช้คนนั้น กรณีอัปโหลดแล้ว
  Widget staticsRiderMe(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่คุณตรวจจับได้ (อัปโหลดแล้ว)",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        displayDataStatics("\t\t\t\tวันนี้", data.countMeRidertoday),
        displayDataStatics("เดือนนี้", data.countMeRidertomonth),
        displayAllStatics(
            "จำนวนรถจักรยานยนต์\nที่คุณตรวจจับทั้งหมด", data.countMeRidertotal),
        const SizedBox(height: 15),
      ],
    );
  }

  ///สถิติของผู้ใช้ในระบบทั้งหมด
  Widget staticsRiderAll(DataStatics data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "จำนวนรถจักรยานยนต์ที่ถูกตรวจจับได้ในระบบ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        displayDataStatics("\t\t\t\tวันนี้", data.countAllRidertoday),
        displayDataStatics("เดือนนี้", data.countAllRidertomonth),
        displayAllStatics(
            "จำนวนรถจักรยานยนต์\nในระบบทั้งหมด", data.countAllRidertotal),
        const SizedBox(height: 15),
      ],
    );
  }

  ///แสดงข้อมูล รายวัน เดือน
  Widget displayDataStatics(String title, int data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$title:',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
            margin: const EdgeInsets.all(8.0),
            height: 25.0,
            width: 80.0,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              // ignore: unnecessary_const
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Align(
                alignment: Alignment.center, child: Text(data.toString()))),
        const Text(
          'คัน',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  ///แสดงข้อมูล ทั้งหมด
  Widget displayAllStatics(String title, int data) {
    print("Screen = ${MediaQuery.of(context).size.width}");
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        MediaQuery.of(context).orientation == Orientation.portrait
            ? SizedBox(width: 17)
            : SizedBox(width: 222),
        Text(
          '$title:',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Container(
            margin: const EdgeInsets.all(8.0),
            height: 25.0,
            width: 80.0,
            decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              // ignore: unnecessary_const
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Align(
                alignment: Alignment.center, child: Text(data.toString()))),
        const Text(
          'คัน',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
