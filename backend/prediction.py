import yfinance as yf
import google.generativeai as genai
import pandas as pd

# Configure Gemini AI (Replace with your actual API key)
genai.configure(api_key="AIzaSyDKMquwq7E8a9SX1eStl_02Rz2cBdlyKUU")

def fetch_stock_data(ticker):
    """Fetch stock data & calculate indicators."""
    try:
        stock = yf.Ticker(ticker)
        data = stock.history(period="6mo")
        if data.empty:
            return None

        data['50_MA'] = data['Close'].rolling(window=50).mean()
        data['200_MA'] = data['Close'].rolling(window=200).mean()
        
        delta = data['Close'].diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
        rs = gain / (loss + 1e-10)  # Avoid division by zero
        data['RSI'] = 100 - (100 / (1 + rs))

        data['20_MA'] = data['Close'].rolling(window=20).mean()
        data['Upper_Band'] = data['20_MA'] + (2 * data['Close'].rolling(window=20).std())
        data['Lower_Band'] = data['20_MA'] - (2 * data['Close'].rolling(window=20).std())

        return data
    except Exception:
        return None

def predict_stock_trend(ticker):
    """Predict stock trends using Gemini AI."""
    stock_data = fetch_stock_data(ticker)
    if stock_data is None:
        return {"error": "Insufficient stock data available."}

    latest_data = stock_data.iloc[-1]

    prompt = f"""
    Predict the short-term trend for {ticker} using technical indicators:

    - 50-day MA: {latest_data['50_MA']:.2f}
    - 200-day MA: {latest_data['200_MA']:.2f}
    - RSI: {latest_data['RSI']:.2f} (Overbought > 70, Oversold < 30)
    - Bollinger Bands: Upper {latest_data['Upper_Band']:.2f}, Lower {latest_data['Lower_Band']:.2f}
    GIVE TREND PREDICTION,RECOMENDATION,REASON IN DIFFERENT LINE

    Will this stock trend UP or DOWN in the next few days? Provide a concise recommendation (BUY, HOLD, or SELL) with a short explanation.
    """
    
    model = genai.GenerativeModel("gemini-1.5-pro")
    response = model.generate_content(prompt)
    return {"prediction": response.text.strip()}
