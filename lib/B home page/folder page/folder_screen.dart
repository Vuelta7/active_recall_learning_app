import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/B%20home%20page/folder%20page/folder_model_widget.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_appbar.dart';
import 'package:learn_n/B%20home%20page/home%20page%20util/home_page_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderPage extends StatefulWidget {
  final String userId;

  const FolderPage({super.key, required this.userId});

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _folders = [];
  String searchQuery = '';
  Map<String, int> _folderPositions = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_updateSearchQuery);
    _loadFolderOrder();
  }

  void _updateSearchQuery() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<void> _loadFolderOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final folderOrder = prefs.getStringList('folderOrder_${widget.userId}');
    if (folderOrder != null) {
      setState(() {
        _folderPositions = {
          for (var item in folderOrder)
            item.split(':')[0]: int.parse(item.split(':')[1])
        };
      });
    }
  }

  Future<void> _saveFolderOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final folderOrder = _folderPositions.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();
    await prefs.setStringList('folderOrder_${widget.userId}', folderOrder);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _folders.removeAt(oldIndex);
      _folders.insert(newIndex, item);

      for (int i = 0; i < _folders.length; i++) {
        _folderPositions[_folders[i].id] = i;
      }
    });
    _saveFolderOrder();
  }

  List<DocumentSnapshot> _filterFolders(List<DocumentSnapshot> docs) {
    return docs.where((folderDoc) {
      final folderData = folderDoc.data() as Map<String, dynamic>;
      final folderName = folderData['folderName'] as String;
      return folderName.toLowerCase().contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Folders',
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.black,
              decoration: const InputDecoration(
                hintText: 'Search Folder',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('folders').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black),
                );
              }

              _folders = _filterFolders(snapshot.data!.docs.where((folderDoc) {
                final folderData = folderDoc.data() as Map<String, dynamic>;
                final accessUsers =
                    List<String>.from(folderData['accessUsers']);
                return folderData['creator'] == widget.userId ||
                    accessUsers.contains(widget.userId);
              }).toList());

              _folders.sort((a, b) {
                final aPos = _folderPositions[a.id] ?? 0;
                final bPos = _folderPositions[b.id] ?? 0;
                return aPos.compareTo(bPos);
              });

              if (_folders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: Text(
                      'No Folder here 🗂️\nCreate one by clicking the Add Folder ➕.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Expanded(
                child: ReorderableListView.builder(
                  itemCount: _folders.length,
                  onReorder: _onReorder,
                  itemBuilder: (context, index) {
                    final folderDoc = _folders[index];
                    final folderData = folderDoc.data() as Map<String, dynamic>;
                    final isImported =
                        List<String>.from(folderData['accessUsers'])
                            .contains(widget.userId);

                    return Container(
                      key: ValueKey(folderDoc.id),
                      margin: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 16),
                      child: FolderModel(
                        folderId: folderDoc.id,
                        headerColor: hexToColor(folderData['color']),
                        folderName: folderData['folderName'],
                        description: folderData['description'],
                        isImported: isImported,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
