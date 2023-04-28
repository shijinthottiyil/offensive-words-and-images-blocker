import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BadScreen extends StatefulWidget {
  const BadScreen({super.key});

  @override
  State<BadScreen> createState() => _BadScreenState();
}

class _BadScreenState extends State<BadScreen> {
  bool _isBad = false;

  void showPop() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('This is a bad word'),
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

  Future<bool> verifyBadWords(String text) async {
    try {
      final Dio dio = Dio();

      Response response = await dio.post(
        'https://neutrinoapi-bad-word-filter.p.rapidapi.com/bad-word-filter',
        options: Options(
          headers: {
            'content-type': 'application/x-www-form-urlencoded',
            'X-RapidAPI-Key':
                '6b272be99emsh614071b2a8ae7e9p1f8dd7jsn6a37d85dfcb1',
            'X-RapidAPI-Host': 'neutrinoapi-bad-word-filter.p.rapidapi.com',
          },
        ),
        data: {
          'content': text,
          'censor-character': '*',
        },
      );

      log(response.data['is-bad'].toString());

      final bool isClean = response.data['is-bad'];
      return isClean;
    } catch (e) {
      log(e.toString());
      return true;
    }
  }

  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text(
          "Bad word Remover",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: SizedBox(
          height: 50,
          width: 350,
          child: CupertinoTextField(
            placeholder: "Enter the text ",
            controller: _controller,
            onSubmitted: (value) async {
              _isBad = await verifyBadWords(value);
              if (_isBad) {
                showPop();
              }
            },
          ),
        ),
      ),
    );
  }
}
