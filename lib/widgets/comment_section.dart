import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';
import '../providers/health_data_provider.dart';

class CommentSection extends StatefulWidget {
  final String targetId;
  final String targetOwnerId;
  const CommentSection({super.key, required this.targetId, required this.targetOwnerId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _controller = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.currentUser;
    if (user == null) return;
    final comment = Comment(
      id: '',
      userId: user.id,
      authorName: user.name,
      targetId: widget.targetId,
      targetOwnerId: widget.targetOwnerId,
      text: text,
      createdAt: DateTime.now(),
    );
    await _firestoreService.addComment(comment);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        StreamBuilder<List<Comment>>(
          stream: _firestoreService.getCommentsForTarget(widget.targetId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
            final comments = snapshot.data!;
            return Column(
              children: comments.map((c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                          Text(c.text, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Add comment...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, size: 18),
              onPressed: _submitComment,
            ),
          ],
        ),
      ],
    );
  }
}
