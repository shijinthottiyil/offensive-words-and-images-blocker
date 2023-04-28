import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class BadImage extends StatefulWidget {
  const BadImage({super.key});

  @override
  State<BadImage> createState() => _BadImageState();
}

class _BadImageState extends State<BadImage> {
  String imgUrl = '';
  TextEditingController _controller = TextEditingController();
  void showPop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adult Content Found'),
          content: const Text('Cannot display this image'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _controller.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isBad = false;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          "Check Image",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Visibility(
            visible: imgUrl.isNotEmpty,
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: NetworkImage(imgUrl),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 350,
            child: CupertinoTextField(
              placeholder: 'Paste the Image link',
              controller: _controller,
              onSubmitted: (value) async {
                _isBad = await verifyBadImage(value);
                log(_isBad.toString());

                if (_isBad) {
                  setState(() {
                    imgUrl = '';
                  });

                  showPop();
                } else {
                  setState(() {
                    imgUrl = _controller.text;
                  });

                  log(imgUrl);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> verifyBadImage(String imageUrl) async {
    bool _isDirty;
    try {
      final dio = Dio();

      FormData formData = FormData.fromMap({
        'url_image': imageUrl,
        'API_KEY': 'e1Z3eqEIjdvA0kcfHCun840FNSmnWanG',
        'task': 'porn_moderation',
        'origin_id': 'xxxxxxxxx',
        'reference_id': 'yyyyyyyy',
      });

      Response respone = await dio.post(
        'https://www.picpurify.com/analyse/1.1',
        data: formData,
      );
      var data = jsonDecode(respone.data);
      log(data["porn_moderation"]["porn_content"].toString());
      return _isDirty = data["porn_moderation"]["porn_content"];
    } catch (e) {
      log(e.toString());
      return _isDirty = false;
    }
  }
}
