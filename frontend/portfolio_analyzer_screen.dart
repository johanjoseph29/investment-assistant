import 'package:flutter/material.dart';

class PortfolioAnalyzerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Portfolio Analyzer"),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Center(
        child: Text("No portfolio data available.",
            style: TextStyle(fontSize: 18, color: Colors.black)),
      ),
    );
  }
}
