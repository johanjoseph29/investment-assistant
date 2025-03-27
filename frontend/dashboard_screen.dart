import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import 'decision_tester_screen.dart';
import 'portfolio_analyzer_screen.dart';
import 'stock_analyzer_screen.dart';
import 'suggestions_screen.dart'; // Import the SuggestionScreen

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.blue.shade600],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text(
                " Investment AI Dashboard",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.all(20),
                  crossAxisCount: 1,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3.5,
                  children: [
                    _buildDashboardCard(
                      context,
                      title: " AI Finance Chatbot",
                      subtitle: "Ask AI about investments & finance!",
                      icon: Icons.chat_bubble_outline,
                      color: Colors.purpleAccent,
                      screen: ChatbotScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Stock Decision Tester",
                      subtitle: "Analyze stocks before buying/selling!",
                      icon: Icons.trending_up,
                      color: Colors.greenAccent,
                      screen: DecisionScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Portfolio Analyzer",
                      subtitle: "Track & analyze your portfolio performance!",
                      icon: Icons.pie_chart,
                      color: Colors.blueAccent,
                      screen: PortfolioAnalyzerScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Stock Predictor",
                      subtitle: "AI-based stock trend prediction!",
                      icon: Icons.auto_graph,
                      color: Colors.orangeAccent,
                      screen: StockAnalyzerScreen(),
                    ),
                    _buildDashboardCard(
                      context,
                      title: "Stock Suggestions",
                      subtitle: "Get stock suggestions based on performance!",
                      icon: Icons.lightbulb,
                      color: Colors.yellowAccent,
                      screen: SuggestionScreen(),  // Add SuggestionScreen here
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required Widget screen,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        color: Colors.white.withOpacity(0.95),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Colors.transparent,
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Ensure text is visible
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      color: Colors.transparent,
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45, // Lighter subtitle for better contrast
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
