import 'package:flutter/material.dart';
import 'package:projectmp/services/firestore.dart';

class NoteDetailPage extends StatefulWidget {
  final String title;
  final String subtitle;
  final String docID;

  const NoteDetailPage({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.docID,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final FireStoreService fireStoreService = FireStoreService();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _subtitleController = TextEditingController(text: widget.subtitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _editNote() {
    String newTitle = _titleController.text;
    String newSubtitle = _subtitleController.text;
    fireStoreService.updateNote(widget.docID, newTitle, newSubtitle);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan diubah')),
    );
  }

  void _deleteNote() async {
    await fireStoreService.deleteNote(widget.docID);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editNote();
              } else if (value == 'delete') {
                _deleteNote();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  title: Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Judul",
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _subtitleController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Konten",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
