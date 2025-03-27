import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DecisionScreen extends StatefulWidget {
  @override
  _DecisionScreenState createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  final TextEditingController _tickerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _holdingsController = TextEditingController();
  final TextEditingController _buyMonthController = TextEditingController();
  final TextEditingController _buyYearController = TextEditingController();
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _targetPriceController = TextEditingController();

  String _selectedAction = "BUY";
  String _selectedInvestorType = "Short-Term";
  String _result = "";

  Future<void> analyzeStock() async {
    var url = Uri.parse("http://127.0.0.1:5000/decision");

    var requestBody = {
      "ticker": _tickerController.text.toUpperCase(),
      "quantity": int.tryParse(_quantityController.text) ?? 0,
      "current_holdings": int.tryParse(_holdingsController.text) ?? 0,
      "investor_type": _selectedInvestorType,
      "action": _selectedAction,
      "buy_month": int.tryParse(_buyMonthController.text),
      "buy_year": int.tryParse(_buyYearController.text),
      "stop_loss": double.tryParse(_stopLossController.text),
      "target_price": double.tryParse(_targetPriceController.text),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _result = """
📈 **Stock:** ${data["ticker"]}
💰 **Buy Price:** ${data["buy_price"] ?? "N/A"}
📊 **Current Price:** ${data["current_price"] ?? "N/A"}
📉 **Profit/Loss:** ${data["profit_or_loss"]}
📝 **AI Analysis:** ${data["gemini_analysis"]}
""";
        });
      } else {
        setState(() {
          _result = "Error: Unable to fetch stock analysis.";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Network error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Decision Tester"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _tickerController,
                decoration: InputDecoration(labelText: "Stock Ticker (e.g. AAPL)"),
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantity"),
              ),
              TextField(
                controller: _holdingsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Current Holdings"),
              ),
              DropdownButtonFormField(
                value: _selectedInvestorType,
                items: ["Short-Term", "Long-Term", "Intraday"].map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedInvestorType = value.toString()),
                decoration: InputDecoration(labelText: "Investor Type"),
              ),
              DropdownButtonFormField(
                value: _selectedAction,
                items: ["BUY", "SELL", "HOLD"].map((action) {
                  return DropdownMenuItem(value: action, child: Text(action));
                }).toList(),
                onChanged: (value) => setState(() => _selectedAction = value.toString()),
                decoration: InputDecoration(labelText: "Action"),
              ),
              TextField(
                controller: _buyMonthController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Buy Month (Optional)"),
              ),
              TextField(
                controller: _buyYearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Buy Year (Optional)"),
              ),
              TextField(
                controller: _stopLossController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Stop Loss (Optional)"),
              ),
              TextField(
                controller: _targetPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Target Price (Optional)"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: analyzeStock,
                child: Text("Analyze Stock"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              ),
              SizedBox(height: 20),
              Text(
                _result,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
