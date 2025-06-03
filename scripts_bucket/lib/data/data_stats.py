import os
from google.cloud import bigquery

# Read environment variables once at module load for clarity and reuse
PROJECT_ID = os.environ.get('PROJECT_ID')
RETAIL_DATASET = os.environ.get('RETAIL_DATASET')
PRODUCTS_TABLE = os.environ.get('PRODUCTS_TABLE')


def get_unique_title_tokens() -> list[str]:
    """
    Returns a unique list of tokens extracted from the title field of the products table.
    Configuration is driven by environment variables set in env.sh (PROJECT_ID, RETAIL_DATASET, PRODUCTS_TABLE).
    """
    # Print the configuration being used
    print(f"[INFO] Using PROJECT_ID={PROJECT_ID}, RETAIL_DATASET={RETAIL_DATASET}, PRODUCTS_TABLE={PRODUCTS_TABLE}")
    # Validate that all required environment variables are set
    if not all([PROJECT_ID, RETAIL_DATASET, PRODUCTS_TABLE]):
        print("[ERROR] PROJECT_ID, RETAIL_DATASET, and PRODUCTS_TABLE must be set in the environment.")
        raise ValueError("PROJECT_ID, RETAIL_DATASET, and PRODUCTS_TABLE must be set in the environment.")

    # Initialize BigQuery client
    client = bigquery.Client(project=PROJECT_ID)
    # Prepare the SQL query to extract unique tokens from the title field
    query = f'''
        SELECT DISTINCT token
        FROM `{PROJECT_ID}.{RETAIL_DATASET}.{PRODUCTS_TABLE}`,
        UNNEST(REGEXP_EXTRACT_ALL(title, r'[^ ]+')) AS token
    '''
    print(f"[INFO] Running BigQuery: {query}")
    # Execute the query
    query_job = client.query(query)
    # Collect tokens from the query result
    tokens = [row.token for row in query_job]
    print(f"[INFO] Retrieved {len(tokens)} unique tokens from BigQuery.")
    return tokens
