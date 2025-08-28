import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/save_username.dart';

class PublicChatPage extends StatefulWidget {
  const PublicChatPage({super.key});
  @override
  State<PublicChatPage> createState() => _PublicChatPageState();
}

class _PublicChatPageState extends State<PublicChatPage> {
  final TextEditingController _msg = TextEditingController();
  final ScrollController _scroll = ScrollController();
  String? _username;
  bool _asking = false;

  @override
  void initState() {
    super.initState();
    _ensureUsername();
  }

  String? _userId;

  Future<void> _ensureUsername() async {
    final saved = await UsernameStore.get();
    final savedUserId = await UsernameStore.getUserId();
    if (!mounted) return;
    if (saved == null || saved.isEmpty) {
      _askUsername(); // first time only
    } else {
      setState(() {
        _username = saved;
        _userId = savedUserId;
      });
    }
  }

  Future<void> _askUsername() async {
    if (_asking) return;
    _asking = true;
    final c = TextEditingController(text: _username ?? '');
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose a username'),
        content: TextField(
          controller: c,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'e.g. nik_007',
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(c.text.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(c.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    _asking = false;

    final clean = (name ?? '').trim();
    if (clean.isEmpty) {
      // force until they enter something
      _askUsername();
      return;
    }
    await UsernameStore.set(clean);
    if (!mounted) return;
    setState(() => _username = clean);
  }

  Future<void> _send() async {
    final text = _msg.text.trim();
    if (text.isEmpty || _username == null) return;

    _msg.clear();
    FocusScope.of(context).unfocus();

    await FirebaseFirestore.instance.collection('public_chat').add({
      'username': _username,
      'user_id': _userId,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),  // ✅ server timestamp
    });

    // scroll to bottom (newest at bottom in our list)
    await Future.delayed(const Duration(milliseconds: 150));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canChat = _username != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Public Chat'),
          actions: [
            if (canChat)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  label: Text(_username!),
                  avatar: CircleAvatar(
                    child: Text(_username!.substring(0, 1).toUpperCase()),
                  ),
                  onPressed: _askUsername, // tap to change name later
                ),
              )
          ],
        ),
        body: Column(
          children: [
            // messages
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('public_chat')
                      .orderBy('timestamp', descending: false)
                      .limit(200)
                      .snapshots(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    final docs = snap.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Say hi 👋 — be the first to chat!'),
                      );
                    }
                    return ListView.builder(
                      controller: _scroll,
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d = docs[i].data();
                        final name = (d['username'] ?? 'user') as String;
                        final msg = (d['message'] ?? '') as String;
                        final you = name == _username;
                        return _MessageTile(
                          username: name,
                          message: msg,
                          isMe: you,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // input area
            SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(blurRadius: 20, spreadRadius: -10, offset: Offset(0, 8)),
                  ],
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _username ?? 'username',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton(
                          onPressed: _askUsername,
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msg,
                            enabled: canChat,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'type message…',
                            ),
                            onSubmitted: (_) {}, // keep newline behavior
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: canChat ? _send : null,
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Message tile widget (bubble style similar to your sketch)
// ──────────────────────────────────────────────────────────────────────────────
class _MessageTile extends StatelessWidget {
  final String username;
  final String message;
  final bool isMe;
  const _MessageTile({
    required this.username,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.surfaceVariant;

    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              child: Text(username.substring(0, 1).toUpperCase()),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
                  child: Text(message),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 18,
              child: Text(username.substring(0, 1).toUpperCase()),
            ),
        ],
      ),
    );
  }
}