import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/home_main_screen.dart';
import 'package:learn_n/C%20folder%20page/add_flashcard_widget.dart';

PreferredSizeWidget insideFolderAppBarWidget(
  BuildContext context, {
  required String folderId,
  required String folderName, // Add folderName parameter
}) {
  return AppBar(
    backgroundColor: Colors.white,
    centerTitle: true,
    title: Text(
      folderName, // Use folderName here
      style: const TextStyle(
        color: Colors.black,
        fontFamily: 'PressStart2P',
      ),
    ),
    leading: IconButton(
      icon: const Icon(
        Icons.list_alt_rounded,
        size: 40,
      ),
      color: Colors.black,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeMainScreen()),
        );
      },
    ),
    actions: [
      AddFlashcardButtonWidget(folderId: folderId),
    ],
    elevation: 0,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(3.0),
      child: Column(
        children: [
          Container(
            color: Colors.black,
            height: 4.0,
          ),
          Container(
            color: Colors.black.withOpacity(0.2),
            height: 2.0,
          ),
        ],
      ),
    ),
  );
}
