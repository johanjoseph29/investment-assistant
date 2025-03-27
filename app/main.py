from flask import Flask, request, jsonify
from flask_cors import CORS
from chatbot import get_finance_response
from DECISION_TESTER import get_stock_analysis  # Importing your unchanged logic
from prediction import predict_stock_trend  # Importing stock prediction function
from suggestion import get_gemini_suggestions, verify_suggestions  # Importing suggestion functions


app = Flask(__name__)
CORS(app)  # Enable CORS for frontend access

# Flask Routes
@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    user_message = data.get("message", "")
    response = get_finance_response(user_message)
    return jsonify({"reply": response})

@app.route("/decision", methods=["POST"])
def decision():
    data = request.json
    result = get_stock_analysis(
        ticker=data["ticker"],
        quantity=data["quantity"],
        current_holdings=data["current_holdings"],
        investor_type=data["investor_type"],
        action=data["action"],
        buy_month=data.get("buy_month"),
        buy_year=data.get("buy_year"),
        stop_loss=data.get("stop_loss"),
        target_price=data.get("target_price"),
    )
    return jsonify(result)

@app.route("/predict_trend", methods=["GET"])
def predict_trend():
    ticker = request.args.get("ticker")
    if not ticker:
        return jsonify({"error": "Stock ticker is required"}), 400

    try:
        prediction = predict_stock_trend(ticker)
        return jsonify({"ticker": ticker, "prediction": prediction})
    except Exception as e:
        return jsonify({"error": f"Prediction failed: {str(e)}"}), 500

# New endpoint for stock suggestions
@app.route("/suggest_stocks", methods=["POST"])
def suggest_stocks():
    data = request.json
    target_ticker = data.get("ticker")
    
    if not target_ticker:
        return jsonify({"error": "Ticker is required"}), 400
    
    # Get stock suggestions using Gemini AI
    gemini_suggestions = get_gemini_suggestions(target_ticker)
    
    if not gemini_suggestions:
        return jsonify({"error": "No suggestions found"}), 500
    
    valid_stocks = verify_suggestions(gemini_suggestions, target_ticker)
    
    return jsonify({
        "suggested_stocks": valid_stocks,
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
