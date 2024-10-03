import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:projectmp/services/firestore.dart';
import 'note_detail_page.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FireStoreService fireStoreService = FireStoreService();
  final TextEditingController searchController = TextEditingController();
  late List<DocumentSnapshot> noteList = [];

  void openNoteDetailPage(String title, String subtitle, String docID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          title: title,
          subtitle: subtitle,
          docID: docID,
        ),
      ),
    );
  }

  void openNoteBox({String? docID}) {
    String title = '';
    String subtitle = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Judul",
              ),
              onChanged: (value) {
                title = value;
              },
            ),
            const SizedBox(height: 22),
            TextField(
              controller: TextEditingController(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Konten",
              ),
              onChanged: (value) {
                subtitle = value;
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                fireStoreService.addNoteWithTitle(
                    title, subtitle, DateTime.now());
              } else {
                fireStoreService.updateNote(docID, title, subtitle);
              }
              Navigator.pop(context);
            },
            child: const Text("Tambahkan"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void navigateToNotePage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NotePage(fireStoreService: fireStoreService),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Harian"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToNotePage,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 4, 1, 12),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Cari',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1, style: BorderStyle.none),
                ),
              ),
              onChanged: (value) async {
                List<DocumentSnapshot> results =
                    await fireStoreService.searchNotes(value);
                setState(() {
                  noteList = results;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: fireStoreService.getNotesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List notelist = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: notelist.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = notelist[index];
                      String docID = document.id;
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String noteText = data['note'];

                      String subtitle = data['subtitle'] ?? '';

                      if (noteText
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase()) ||
                          subtitle
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                        dynamic createdAt = data['createdAt'];
                        DateTime? createdAtDateTime;
                        if (createdAt is Timestamp) {
                          createdAtDateTime = createdAt.toDate();
                        } else if (createdAt is DateTime) {
                          createdAtDateTime = createdAt;
                        }
                        if (createdAtDateTime != null) {
                          return GestureDetector(
                            onTap: () {
                              openNoteDetailPage(
                                  data['note'], data['subtitle'] ?? '', docID);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 1, 0, 1),
                              child: Card(
                                elevation: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(noteText),
                                              // const SizedBox(
                                              //   height: 12,
                                              // ),
                                              // Text(subtitle)
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              DateFormat.Hm()
                                                  .format(createdAtDateTime),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              DateFormat.yMMMd()
                                                  .format(createdAtDateTime),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return const SizedBox();
                      }
                    },
                  );
                } else {
                  return const Text("no notes..");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
