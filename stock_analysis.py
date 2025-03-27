import yfinance as yf
import pandas as pd
import numpy as np
import requests
from bs4 import BeautifulSoup
import nltk
from nltk.sentiment import SentimentIntensityAnalyzer
import google.generativeai as genai

# Download required NLTK data
nltk.download('vader_lexicon')
sia = SentimentIntensityAnalyzer()

# Configure Gemini AI API
genai.configure(api_key="YOUR_GEMINI_API_KEY")  # Replace with your actual key

def fetch_stock_data(ticker):
    stock = yf.Ticker(ticker)
    data = stock.history(period="6mo")
    
    # Calculate Moving Averages
    data['50_MA'] = data['Close'].rolling(window=50).mean()
    data['200_MA'] = data['Close'].rolling(window=200).mean()
    
    # Calculate Relative Strength Index (RSI)
    delta = data['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    rs = gain / loss
    data['RSI'] = 100 - (100 / (1 + rs))
    
    # Calculate Bollinger Bands
    data['20_MA'] = data['Close'].rolling(window=20).mean()
    data['Upper_Band'] = data['20_MA'] + (2 * data['Close'].rolling(window=20).std())
    data['Lower_Band'] = data['20_MA'] - (2 * data['Close'].rolling(window=20).std())
    
    # Calculate MACD
    short_ema = data['Close'].ewm(span=12, adjust=False).mean()
    long_ema = data['Close'].ewm(span=26, adjust=False).mean()
    data['MACD'] = short_ema - long_ema
    data['Signal_Line'] = data['MACD'].ewm(span=9, adjust=False).mean()
    
    # Detect Unusual Volume Spikes
    data['Avg_Volume'] = data['Volume'].rolling(window=50).mean()
    data['Volume_Anomaly'] = data['Volume'] > (1.5 * data['Avg_Volume'])
    
    # Calculate ADX (Trend Strength Indicator)
    high_low = data['High'] - data['Low']
    high_close = np.abs(data['High'] - data['Close'].shift())
    low_close = np.abs(data['Low'] - data['Close'].shift())
    true_range = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
    atr = true_range.rolling(window=14).mean()
    data['ADX'] = atr / data['Close'] * 100
    
    return data

def fetch_stock_news(ticker):
    url = f'https://finance.yahoo.com/quote/{ticker}/news'
    headers = {'User-Agent': 'Mozilla/5.0'}
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.text, 'html.parser')
    
    news = []
    for item in soup.find_all('h3')[:10]:  # Extract relevant titles
        title_text = item.get_text()
        link = item.find('a')
        if link and title_text:
            sentiment_score = sia.polarity_scores(title_text)['compound']  # Sentiment Analysis
            news.append({
                "headline": title_text, 
                "url": 'https://finance.yahoo.com' + link['href'], 
                "sentiment": sentiment_score
            })
    
    if not news:
        news.append({"headline": "No recent relevant news found", "url": "N/A", "sentiment": 0})
    
    return news

def analyze_with_gemini(ticker, stock_data, news):
    news_text = "\n".join([f"- {n['headline']} ({n['url']}) [Sentiment: {n['sentiment']}]" for n in news])
    
    prompt = f"""
    Analyze the following stock data, technical indicators, and recent news articles:
    
    Stock Ticker: {ticker}
    Stock Data (Last 10 Days):
    {stock_data.tail(10).to_string()}
    
    Technical Indicators:
    - 50-day Moving Average: {stock_data['50_MA'].iloc[-1]:.2f}
    - 200-day Moving Average: {stock_data['200_MA'].iloc[-1]:.2f}
    - RSI: {stock_data['RSI'].iloc[-1]:.2f} (Overbought > 70, Oversold < 30)
    - Bollinger Bands: Upper {stock_data['Upper_Band'].iloc[-1]:.2f}, Lower {stock_data['Lower_Band'].iloc[-1]:.2f}
    - MACD: {stock_data['MACD'].iloc[-1]:.2f}, Signal Line: {stock_data['Signal_Line'].iloc[-1]:.2f}
    - Volume Anomaly Detected: {'Yes' if stock_data['Volume_Anomaly'].iloc[-1] else 'No'}
    - ADX (Trend Strength): {stock_data['ADX'].iloc[-1]:.2f} (Strong Trend > 25)
    
    Recent News Headlines & Sentiments:
    {news_text}
    
    Based on this data, predict tomorrow’s trend and provide a clear recommendation: BUY, SELL, or HOLD. Explain your reasoning concisely.
    """
    
    model = genai.GenerativeModel("gemini-1.5-pro")
    response = model.generate_content(prompt)
    return response.text
