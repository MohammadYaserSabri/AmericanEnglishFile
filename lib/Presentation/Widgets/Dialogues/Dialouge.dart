import 'package:flutter/material.dart';

    void showWaitingDialouge(BuildContext context){

       showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext showDialogueContext) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Logging in..."),
            ],
          ),
        );
      },
    );

      
    }