import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/comment.dart';

class ClinicianCommentsWidget extends StatelessWidget {
  final String userId;

  const ClinicianCommentsWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Comment>>(
      stream: FirestoreService().getCommentsForUser(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final unreadComments = snapshot.data!.where((c) => !c.isRead).toList();
        if (unreadComments.isEmpty) return const SizedBox.shrink();

        return Card(
          color: Colors.blue.shade50,
          margin: const EdgeInsets.all(16),
          child: ExpansionTile(
            leading: Icon(Icons.notifications_active, color: Colors.blue.shade700),
            title: Text(
              'New Comments from Doctor (${unreadComments.length})',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            children: unreadComments.map((comment) {
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person, size: 20),
                ),
                title: Text(comment.authorName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment.text),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(comment.createdAt),
                      style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    await FirestoreService().markCommentAsRead(comment.id);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
