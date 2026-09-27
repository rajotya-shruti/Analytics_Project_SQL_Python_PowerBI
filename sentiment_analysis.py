import os
import pandas as pd
import psycopg2
import nltk
from dotenv import load_dotenv
from nltk.sentiment.vader import SentimentIntensityAnalyzer


load_dotenv()

# Download VADER for sentiment scoring
nltk.download('vader_lexicon', quiet=True)
sia = SentimentIntensityAnalyzer()

# Connect to PostgreSQL

def fetch_reviews():
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432")
    )
    
    query = """
    SELECT 
        reviewid AS review_id,
        customerid AS customer_id,
        productid AS product_id,
        reviewdate AS review_date,
        rating,
        reviewtext AS review_text
    FROM customer_reviews;
    """
    
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df

print("Connecting securely to PostgreSQL database...")
df = fetch_reviews()

# VADER Score Calculation

def calculate_sentiment_score(text):
    if pd.isna(text) or not str(text).strip():
        return 0.0
    return sia.polarity_scores(str(text))['compound']

df['sentiment_score'] = df['review_text'].apply(calculate_sentiment_score)

# Sentiment Buckets (Positive, Neutral, Negative) 
def categorize_sentiment(score):
    if score >= 0.05:
        return 'Positive'
    elif score <= -0.05:
        return 'Negative'
    else:
        return 'Neutral'

df['sentiment_bucket'] = df['sentiment_score'].apply(categorize_sentiment)

# Aspect-Based Keyword / Topic Extraction 
def extract_review_topic(text):
    """
    Categorizes reviews using bigram
    """
    text = str(text).lower()
    
    # Topic mapping based on topic_eda.py results
    if any(k in text for k in ['price', 'cost', 'expensive', 'cheap', 'cheaper', 'worth', 'value', 'money']):
        return 'Pricing & Value'
    elif any(k in text for k in ['shipping', 'delivery', 'arrived', 'package', 'packaged', 'fast', 'slow', 'delay', 'quick']):
        return 'Shipping & Logistics'
    elif any(k in text for k in ['quality', 'material', 'broke', 'durable', 'sturdy', 'build', 'defect', 'notch', 'instructions', 'unclear']):
        return 'Product Quality'
    elif any(k in text for k in ['service', 'support', 'help', 'helpful', 'agent', 'refund', 'return']):
        return 'Customer Support'
        
    return 'General Experience'

df['review_topic'] = df['review_text'].apply(extract_review_topic)

# Export File as CSV

output_filename = 'customer_reviews_sa.csv'
df.to_csv(output_filename, index=False)

print(f"Success! Saved file as '{output_filename}'.")
print("\nPreview of output data:")
print(df[['review_id', 'rating', 'sentiment_score', 'sentiment_bucket', 'review_topic']].head())
