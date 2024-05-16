import 'dart:async';

import 'package:flutter/material.dart';

Future<void> testingMain() async {
  runApp(
    MaterialApp(
      home: FadeInImage.assetNetwork(
        placeholder: 'assets/img/photo_placeholder_0.png',
        image:
            'https://raw.githubusercontent.com/svthalia/Reaxit/3e3a74364f10cd8de14ac1f74de8a05aa6d00b28/assets/img/default-avatar.jpg',
        fit: BoxFit.cover,
      ),
    ),
  );
}
