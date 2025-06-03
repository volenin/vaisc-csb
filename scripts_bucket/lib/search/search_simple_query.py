# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Call Retail API to search for a products in a catalog using only search query.
#

# [START retail_search_simple_query]
import os
import time
import random
import google.auth
from google.cloud.retail import SearchRequest, SearchServiceClient

# Remove sys.path modification since running from lib/ makes it unnecessary
# from data.data_stats import get_unique_title_tokens
print("[INFO] Attempting to import get_unique_title_tokens from data.data_stats...")
from data.data_stats import get_unique_title_tokens
print("[INFO] Successfully imported get_unique_title_tokens.")

# Read configuration from environment variables at module load for clarity and reuse
CATALOG_ID = os.environ.get('CATALOG_ID', 'default_catalog')
LOCATION = os.environ.get('LOCATION', 'global')
PROJECT_ID = os.environ.get('PROJECT_ID')

print("[INFO] Reading PROJECT_ID from environment variables...")
if not PROJECT_ID:
    print("[ERROR] PROJECT_ID must be set in the environment.")
    raise ValueError("PROJECT_ID must be set in the environment.")
print(f"[INFO] PROJECT_ID: {PROJECT_ID}")

# Define MAX_REQUESTS as a variable
MAX_REQUESTS = 30

# get search service request:
def get_search_request(query: str):
    """
    Builds and returns a SearchRequest object for the Retail API using environment variables for configuration.
    """
    print("[INFO] Reading CATALOG_ID and LOCATION from environment variables...")
    print(f"[INFO] CATALOG_ID: {CATALOG_ID}, LOCATION: {LOCATION}, PROJECT_ID: {PROJECT_ID}")
    if not PROJECT_ID:
        print("[ERROR] PROJECT_ID must be set in the environment.")
        raise ValueError("PROJECT_ID must be set in the environment.")
    # Build the search placement string
    default_search_placement = (
        f"projects/{PROJECT_ID}/locations/{LOCATION}/catalogs/{CATALOG_ID}/placements/default_search"
    )
    print(f"[INFO] Using search placement: {default_search_placement}")

    # Create the SearchRequest object
    search_request = SearchRequest()
    search_request.placement = default_search_placement  # Placement is used to identify the Serving Config name.
    search_request.query = query
    search_request.visitor_id = "123456"  # A unique identifier to track visitors
    search_request.page_size = 10

    print("---search request:---")
    print(search_request)

    return search_request


def search(query_phrase):
    """
    Executes a search using the provided query phrase and prints the results.
    """
    print(f"[INFO] Running search for query phrase: '{query_phrase}'")
    search_request = get_search_request(query_phrase)
    search_response = SearchServiceClient().search(search_request)

    print("---search response---")
    if not search_response.results:
        print("The search operation returned no matching results.")
    else:
        print(search_response)
    return search_response


def main():
    """
    Main execution function: fetches unique tokens and runs MAX_REQUESTS searches with random tokens.
    """
    print("[INFO] Fetching unique title tokens from products table...")
    tokens = get_unique_title_tokens()
    if not tokens:
        print("[ERROR] No tokens found in products table.")
        raise ValueError("No tokens found in products table.")
    print(f"[INFO] Retrieved {len(tokens)} unique tokens.")
    for i in range(MAX_REQUESTS):
        query_phrase = random.choice(tokens)
        print(f"\n--- Iteration {i+1}/{MAX_REQUESTS}: Query phrase: '{query_phrase}' ---")
        search(query_phrase)

        print("[INFO] Sleeping for 5 seconds before next search...")
        time.sleep(5)

if __name__ == "__main__":
    main()
# [END retail_search_simple_query]
