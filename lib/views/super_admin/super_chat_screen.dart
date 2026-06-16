import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driving_school/const.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

class SuperChatScreen extends StatefulWidget {
  final bool isSuperAdmin;
  const SuperChatScreen({super.key, required this.isSuperAdmin});

  @override
  State<SuperChatScreen> createState() => _SuperChatScreenState();
}

class _SuperChatScreenState extends State<SuperChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String chatId = 'main_branch_chat';

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    
    String senderId = widget.isSuperAdmin ? 'SUPER_ADMIN' : 'ADMIN';
    
    await _firestore
        .collection('super_admin_chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': _msgController.text.trim(),
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(EvaIcons.arrow_ios_back_outline, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isSuperAdmin ? 'Chat with Main Admin' : 'Chat with Super Admin', 
          style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)
        ),
        backgroundColor: widget.isSuperAdmin ? Colors.black87 : defaultBlue,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('super_admin_chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                final messages = snapshot.data!.docs;
                final mySenderId = widget.isSuperAdmin ? 'SUPER_ADMIN' : 'ADMIN';
                
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == mySenderId;
                    
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe 
                            ? (widget.isSuperAdmin ? Colors.black87 : defaultBlue) 
                            : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0,2))
                          ]
                        ),
                        child: Text(
                          msg['text'] ?? '',
                          style: GoogleFonts.epilogue(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.epilogue(color: Colors.grey.shade400),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: widget.isSuperAdmin ? Colors.black87 : defaultBlue,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
