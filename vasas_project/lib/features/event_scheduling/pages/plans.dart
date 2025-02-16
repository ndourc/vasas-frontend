import 'package:flutter/material.dart';

class StudyPlansPage extends StatelessWidget {
  const StudyPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Plans'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Math Study Plan'),
            subtitle: const Text('Focus on problem-solving and past papers'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to detailed study plan
            },
          ),
          ListTile(
            title: const Text('Biology Study Plan'),
            subtitle: const Text('Review notes and diagrams'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to detailed study plan
            },
          ),
          ListTile(
            title: const Text('History Study Plan'),
            subtitle: const Text('Study timelines and key events'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Navigate to detailed study plan
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Logic to create a new study plan
            },
            child: const Text('Create New Plan'),
          ),
        ],
      ),
    );
  }
}
