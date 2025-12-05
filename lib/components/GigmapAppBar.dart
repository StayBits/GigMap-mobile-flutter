import 'package:flutter/material.dart';

class GigMapAppBar extends AppBar {
  GigMapAppBar({
    Key? key,
    required BuildContext context,
    bool showBackButton = true,
    String title = "GigMap"
  }) : super(
         key: key,
         backgroundColor: Colors.white,
         elevation: 0,
         leading: showBackButton
             ? IconButton(
                 icon: const Icon(Icons.arrow_back, color: Color(0xFF5C0F1A)),
                 onPressed: () => Navigator.pop(context),
               )
             : null,
         centerTitle: true,
         title: Text(
           title,
           style: TextStyle(
             color: Color(0xFF5C0F1A),
             fontWeight: FontWeight.bold,
           ),
         ),
         actions: const [
           Padding(
             padding: EdgeInsets.only(right: 16.0),
             child: Icon(Icons.notifications_none, color: Color(0xFF5C0F1A)),
           ),
         ],
       );
}
