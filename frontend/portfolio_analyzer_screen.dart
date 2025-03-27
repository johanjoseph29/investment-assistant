import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PortfolioAnalyzerScreen extends StatefulWidget {
  @override
  _PortfolioAnalyzerScreenState createState() => _PortfolioAnalyzerScreenState();
}

class _PortfolioAnalyzerScreenState extends State<PortfolioAnalyzerScreen> {
  Map<String, dynamic>? portfolioData;
  String? aiInsights;
  bool isLoading = false;

  // API Base URL
  final String baseUrl = "http://127.0.0.1:5000";  // Update if using a hosted Flask server

  // Fetch portfolio analysis
  Future<void> fetchPortfolioAnalysis() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/analyze_portfolio"));
      if (response.statusCode == 200) {
        setState(() {
          portfolioData = json.decode(response.body);
        });
      }
    } catch (error) {
      print("Error fetching portfolio: $error");
    }
    setState(() => isLoading = false);
  }

  // Fetch AI insights
  Future<void> fetchAIInsights() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("$baseUrl/gemini_insights"));
      if (response.statusCode == 200) {
        setState(() {
          aiInsights = json.decode(response.body)['gemini_analysis'];
        });
      }
    } catch (error) {
      print("Error fetching AI insights: $error");
    }
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchPortfolioAnalysis();
    fetchAIInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📊 Portfolio Analyzer"),
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              fetchPortfolioAnalysis();
              fetchAIInsights();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : portfolioData == null
          ? Center(child: Text("No portfolio data available."))
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Profit/Loss Summary
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "💰 Total Profit/Loss",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "₹${portfolioData!['total_profit_loss'].toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: portfolioData!['total_profit_loss'] >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Portfolio List
            Expanded(
              child: ListView.builder(
                itemCount: portfolioData!['portfolio_analysis'].length,
                itemBuilder: (context, index) {
                  var stock = portfolioData!['portfolio_analysis'][index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade800,
                        child: Text(stock["Ticker"][0], style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        stock["Ticker"],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shares: ${stock['Total Shares']}"),
                          Text("Avg. Buy Price: ₹${stock['Avg Buy Price'].toStringAsFixed(2)}"),
                          Text("Current Price: ₹${stock['Current Price'].toStringAsFixed(2)}"),
                        ],
                      ),
                      trailing: Text(
                        "₹${stock['Profit/Loss'].toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: stock['Profit/Loss'] >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),

            // AI Insights
            aiInsights == null
                ? CircularProgressIndicator()
                : Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🔍 AI Investment Insights",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(aiInsights!, style: TextStyle(fontSize: 16)),
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
