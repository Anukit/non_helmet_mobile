import 'package:flutter/material.dart';
import 'package:non_helmet_mobile/models/data_statics.dart';

class ShowStatPage extends StatefulWidget {
  DataStatics dataStat;
  ShowStatPage(this.dataStat, {Key? key}) : super(key: key);

  @override
  State<ShowStatPage> createState() => _ShowStatPageState();
}

class _ShowStatPageState extends State<ShowStatPage> {
  double? valueWidth;

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
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      // is portrait
      valueWidth = MediaQuery.of(context).size.width - 60;
    } else {
      // is landscape
      valueWidth = MediaQuery.of(context).size.width / 2;
    }
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
        const SizedBox(height: 15),
        Card(
            color: Colors.yellow.shade100,
            child: SizedBox(
              width: valueWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '\t\tทั้งหมด:',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(children: [
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
                            alignment: Alignment.center,
                            child: Text(data.countRiderNotup.toString()))),
                    const Text(
                      'คัน\t\t',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ])
                ],
              ),
            )),
        const SizedBox(height: 15),
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
        displayDataStatics("\t\tวันนี้:", data.countMeRidertoday),
        displayDataStatics("\t\tเดือนนี้:", data.countMeRidertomonth),
        displayAllStatics("\t\tจำนวนรถจักรยานยนต์\n\t\tที่คุณตรวจจับทั้งหมด:",
            data.countMeRidertotal),
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
        displayDataStatics("\t\tวันนี้:", data.countAllRidertoday),
        displayDataStatics("\t\tเดือนนี้:", data.countAllRidertomonth),
        displayAllStatics("\t\tจำนวนรถจักรยานยนต์\n\t\tในระบบทั้งหมด:",
            data.countAllRidertotal),
        const SizedBox(height: 15),
      ],
    );
  }

  ///แสดงข้อมูล รายวัน เดือน
  Widget displayDataStatics(String title, int data) {
    return Card(
        color: Colors.yellow.shade100,
        child: SizedBox(
          width: valueWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(children: [
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
                        alignment: Alignment.center,
                        child: Text(data.toString()))),
                const Text(
                  'คัน\t\t',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ])
            ],
          ),
        ));
  }

  ///แสดงข้อมูล ทั้งหมด
  Widget displayAllStatics(String title, int data) {
    return Card(
        color: Colors.yellow.shade100,
        child: SizedBox(
          width: valueWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              Row(children: [
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
                      alignment: Alignment.center,
                      child: Text(data.toString())),
                ),
                const Text(
                  'คัน\t\t',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ])
            ],
          ),
        ));
  }
}
