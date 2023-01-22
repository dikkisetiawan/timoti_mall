import 'package:flutter/material.dart';

void PopPageUntil(int popTimes, BuildContext context){
  int count = 0;
  Navigator.popUntil(context, (route) {
    return count++ == popTimes;
  });
}

