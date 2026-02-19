import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/comment.dart';
import '../services/firestore_service.dart';
import '../providers/auth_provider.dart';

class CommentSection extends StatefulWidget {
  final String targetId;
  const CommentSection({super.key, required this.targetId});

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
      targetId: widget.targetId,
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
        const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
        StreamBuilder<List<Comment>>(
          stream: _firestoreService.getCommentsForTarget(widget.targetId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            final comments = snapshot.data!;
            return Column(
              children: comments.map((c) => ListTile(
                title: Text(c.text),
                subtitle: Text('By ${c.userId} on ${c.createdAt.toLocal()}'),
              )).toList(),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Add a comment...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ],
        ),
      ],
    );
  }
}
