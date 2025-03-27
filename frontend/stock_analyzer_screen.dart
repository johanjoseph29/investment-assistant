import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For loading spinner

class StockAnalyzerScreen extends StatefulWidget {
  @override
  _StockAnalyzerScreenState createState() => _StockAnalyzerScreenState();
}

class _StockAnalyzerScreenState extends State<StockAnalyzerScreen> {
  bool _isLoading = false;
  String _prediction = '';
  String _recommendation = '';
  String _reason = '';

  final TextEditingController _tickerController = TextEditingController();

  // Fetch stock prediction
  Future<void> fetchStockPrediction(String ticker) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      Uri.parse('http://127.0.0.1:5000/predict_trend?ticker=$ticker'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        // Parsing the prediction, recommendation, and reason directly from the response
        String predictionText = data['prediction']['prediction'];

        // Splitting prediction text and extracting the parts
        List<String> parts = predictionText.split("\n");
        if (parts.isNotEmpty) {
          _prediction = parts[0]; // e.g., "TREND PREDICTION: Likely UP"
        }

        // Extracting recommendation if it contains "RECOMMENDATION:" text, without repeating
        if (parts.length > 1 && parts[1].contains("RECOMMENDATION:")) {
          _recommendation = parts[1].replaceAll('RECOMMENDATION:', '').trim(); // Removing duplicate label
        }

        // Extracting reason if it contains "REASON:" text, without repeating
        if (parts.length > 2 && parts[2].contains("REASON:")) {
          _reason = parts[2].replaceAll('REASON:', '').trim(); // Removing duplicate label
        }
      });
    } else {
      setState(() {
        _prediction = 'Error fetching data';
        _recommendation = '';
        _reason = '';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stock Analyzer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField for stock ticker input
            TextField(
              controller: _tickerController,
              decoration: InputDecoration(
                labelText: 'Enter Stock Ticker',
                hintText: 'e.g., TCS.NS',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Predict button
            ElevatedButton(
              onPressed: () {
                if (_tickerController.text.isNotEmpty) {
                  fetchStockPrediction(_tickerController.text);
                }
              },
              child: Text('Predict'),
            ),
            SizedBox(height: 20),
            // Loading indicator
            _isLoading
                ? Center(
              child: SpinKitFadingCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display prediction result
                if (_prediction.isNotEmpty)
                  Text(
                    _prediction,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                if (_recommendation.isNotEmpty)
                  Text(
                    'Recommendation: $_recommendation',
                    style: TextStyle(fontSize: 16),
                  ),
                if (_reason.isNotEmpty)
                  Text(
                    'Reason: $_reason',
                    style: TextStyle(fontSize: 16),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
