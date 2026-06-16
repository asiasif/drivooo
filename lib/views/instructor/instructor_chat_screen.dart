import 'package:driving_school/controller/instructor_controller.dart';
import 'package:driving_school/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:icons_plus/icons_plus.dart';

class InstructorChatScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const InstructorChatScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<InstructorChatScreen> createState() => _InstructorChatScreenState();
}

class _InstructorChatScreenState extends State<InstructorChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorController = Provider.of<InstructorController>(context, listen: false);
    final userController = Provider.of<UserController>(context, listen: false);
    final instructorId = instructorController.currentInstructor?.instructorID ?? '';
    final instructorName = instructorController.currentInstructor?.instructorName ?? 'Instructor';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17),
            ),
            Text(
              'Student',
              style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: userController.getInstructorMessages(
                instructorId: instructorId,
                studentId: widget.studentId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text(
                          'No messages yet.\nSay hello to ${widget.studentName}!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.epilogue(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == instructorId;
                    final text = msg['text'] ?? '';
                    String timeStr = '';
                    try {
                      final dt = DateTime.parse(msg['timestamp'] as String);
                      timeStr = DateFormat('hh:mm a').format(dt);
                    } catch (_) {}

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              text,
                              style: GoogleFonts.epilogue(
                                color: isMe ? Colors.white : Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeStr,
                              style: GoogleFonts.epilogue(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.epilogue(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () {
                      final text = _messageController.text;
                      if (text.trim().isNotEmpty) {
                        userController.sendInstructorMessage(
                          instructorId: instructorId,
                          studentId: widget.studentId,
                          text: text,
                          senderId: instructorId,
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
