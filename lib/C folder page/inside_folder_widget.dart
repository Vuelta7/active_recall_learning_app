import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/C%20folder%20page/add_question_screen.dart';
import 'package:learn_n/C%20folder%20page/leaderboards.dart';
import 'package:learn_n/C%20folder%20page/questions_page.dart';

import 'choose_mode_dialog.dart';

class InsideFolderMain extends StatefulWidget {
  final String folderId;
  final String folderName;
  final Color headerColor;

  const InsideFolderMain({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.headerColor,
  });

  @override
  State<InsideFolderMain> createState() => _InsideFolderMainState();
}

class _InsideFolderMainState extends State<InsideFolderMain> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) async {
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      try {
        final questionsSnapshot = await FirebaseFirestore.instance
            .collection('folders')
            .doc(widget.folderId)
            .collection('questions')
            .get();

        final questions = questionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            "id": doc.id,
            "question": data['question']?.toString() ?? '',
            "answer": data['answer']?.toString() ?? '',
          };
        }).toList();

        if (questions.isNotEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return ChooseModeDialog(
                folderName: widget.folderName,
                folderId: widget.folderId,
                headerColor: widget.headerColor,
                questions: questions,
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions available to play.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    } else if (index == 2) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'PressStart2P',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              size: 30, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          QuestionsPage(folderId: widget.folderId),
          Container(),
          LeaderboardPage(folderId: widget.folderId),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddFlashCardScreen(folderId: widget.folderId),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_rounded, size: 50),
            label: 'Questions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill_rounded, size: 50),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard, size: 50),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
