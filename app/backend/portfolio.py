import yfinance as yf
import pandas as pd
import os

# CSV file to store portfolio data
CSV_FILE = "portfolio.csv"

# Load portfolio (if file exists)
if os.path.exists(CSV_FILE):
    portfolio = pd.read_csv(CSV_FILE)
else:
    portfolio = pd.DataFrame(columns=["Ticker", "Type", "Quantity", "Price", "Month", "Year", "Profit/Loss"])

# Buy/Sell Stocks
def update_portfolio(action):
    global portfolio

    ticker = input("Enter stock ticker (e.g., TCS.NS, RELIANCE.NS): ").strip().upper()
    quantity = int(input("Enter quantity: "))
    month = int(input("Enter buy/sell month (1-12): "))
    year = int(input("Enter buy/sell year (YYYY): "))
    
    stock = yf.Ticker(ticker)
    history = stock.history(start=f"{year}-{month:02d}-01", period="1mo")
    
    if history.empty:
        print("No historical price data available.")
        return
    
    trade_price = history['Close'].iloc[0]  # Closing price of first available day
    
    if action == "BUY":
        new_entry = pd.DataFrame([{
            "Ticker": ticker, "Type": "BUY", "Quantity": quantity,
            "Price": trade_price, "Month": month, "Year": year, "Profit/Loss": None
        }])
        portfolio = pd.concat([portfolio, new_entry], ignore_index=True)
        print(f"Bought {quantity} shares of {ticker} at ₹{trade_price}")

    elif action == "SELL":
        if ticker not in portfolio["Ticker"].values:
            print("No shares to sell!")
            return
        
        # Calculate profit/loss
        total_cost, total_sold = 0, 0
        remaining_quantity = quantity
        profit_loss = 0

        for index, row in portfolio.iterrows():
            if row["Ticker"] == ticker and row["Type"] == "BUY" and remaining_quantity > 0:
                sell_qty = min(remaining_quantity, row["Quantity"])
                total_cost += sell_qty * row["Price"]
                total_sold += sell_qty * trade_price
                profit_loss += (sell_qty * trade_price) - (sell_qty * row["Price"])

                # Update quantity
                portfolio.at[index, "Quantity"] -= sell_qty
                remaining_quantity -= sell_qty

        new_entry = pd.DataFrame([{
            "Ticker": ticker, "Type": "SELL", "Quantity": quantity,
            "Price": trade_price, "Month": month, "Year": year, "Profit/Loss": profit_loss
        }])
        portfolio = pd.concat([portfolio, new_entry], ignore_index=True)

        print(f"Sold {quantity} shares of {ticker} at ₹{trade_price}")
        print(f"Profit/Loss: {'Profit' if profit_loss > 0 else 'Loss'} of ₹{profit_loss:.2f}")

    # Save to CSV
    portfolio.to_csv(CSV_FILE, index=False)

# Menu
while True:
    choice = input("\n1. Buy Stock\n2. Sell Stock\n3. View Portfolio\n4. Exit\nChoose an option: ").strip()

    if choice == "1":
        update_portfolio("BUY")
    elif choice == "2":
        update_portfolio("SELL")
    elif choice == "3":
        print("\nPortfolio:\n", portfolio)
    elif choice == "4":
        break
    else:
        print("Invalid choice! Try again.")
