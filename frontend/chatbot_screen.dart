import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      messages.add({'sender': 'You', 'text': message});
    });

    var url = Uri.parse("http://127.0.0.1:5000/chat");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages.add({'sender': 'Finance Bot', 'text': data['reply']});
        });
      } else {
        setState(() {
          messages.add({'sender': 'Finance Bot', 'text': 'Error: Could not get a response!'});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({'sender': 'Finance Bot', 'text': 'Network error, try again!'});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Finance Chatbot'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['sender'] == 'You'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: message['sender'] == 'You'
                          ? Colors.blue[100]
                          : Colors.blue[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${message['sender']}: ${message['text']}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about investments, stocks...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
