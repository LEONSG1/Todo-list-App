import 'package:flutter/material.dart';
import 'package:projectmp/services/firestore.dart';

class NotePage extends StatelessWidget {
  final FireStoreService fireStoreService;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  NotePage({Key? key, required this.fireStoreService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              String title = titleController.text;
              String subtitle = subtitleController.text;
              fireStoreService.addNoteWithTitle(
                  title, subtitle, DateTime.now());
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Container(
        color: Colors.white10,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Judul",
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: subtitleController,
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
