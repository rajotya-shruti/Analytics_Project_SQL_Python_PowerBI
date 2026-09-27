import os
import pandas as pd
import psycopg2
from dotenv import load_dotenv
from sklearn.feature_extraction.text import CountVectorizer

load_dotenv()

def fetch_review_texts():
    """Pulls review text from Postgres"""
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        database=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        port=os.getenv("DB_PORT", "5432")
    )
    
    query = "SELECT reviewtext AS review_text FROM customer_reviews;"
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df['review_text'].dropna()

if __name__ == "__main__":
    print("Fetching reviews for EDA...")
    text_data = fetch_review_texts()

    # Extract Top 20 Most Frequent Two-Word Phrases (Bigrams)
    vectorizer = CountVectorizer(stop_words='english', ngram_range=(2, 2))
    X = vectorizer.fit_transform(text_data)
    
    bigram_counts = pd.DataFrame(
        X.sum(axis=0).T, 
        index=vectorizer.get_feature_names_out(), 
        columns=['frequency']
    ).sort_values(by='frequency', ascending=False)

    print("\n--- Top 20 Customer Phrases (Bigrams) ---")
    print(bigram_counts.head(20))