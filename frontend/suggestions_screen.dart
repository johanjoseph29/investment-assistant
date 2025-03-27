import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SuggestionScreen extends StatefulWidget {
  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen> {
  final TextEditingController _tickerController = TextEditingController();
  String _stockTicker = '';
  bool _isLoading = false;
  Map<String, dynamic> _suggestions = {};
  String _errorMessage = '';

  Future<void> _fetchSuggestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/suggest_stocks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ticker': _stockTicker}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _suggestions = json.decode(response.body);
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch suggestions';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Suggestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock Ticker Input
            TextField(
              controller: _tickerController,
              decoration: InputDecoration(
                labelText: 'Enter Stock Ticker (e.g., TCS.NS)',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _stockTicker = text;
                });
              },
            ),
            SizedBox(height: 20),
            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_stockTicker.isNotEmpty) {
                  _fetchSuggestions();
                } else {
                  setState(() {
                    _errorMessage = 'Please enter a valid ticker';
                  });
                }
              },
              child: Text('Get Suggestions'),
            ),
            SizedBox(height: 20),
            // Loading Spinner
            if (_isLoading)
              Center(child: SpinKitFadingCircle(color: Colors.blue)),
            // Error Message
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            // Results
            if (_suggestions.isNotEmpty) ...[
              SizedBox(height: 20),
              Text('Suggested Stocks:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Suggested Tickers:'),
              for (var ticker in _suggestions['suggested_stocks'] ?? [])
                Text(ticker),
              SizedBox(height: 10),
              Text('Stocks that were not similar or had no data:'),
              for (var ticker in _suggestions['invalid_stocks'] ?? [])
                Text(ticker),
            ],
          ],
        ),
      ),
    );
  }
}
