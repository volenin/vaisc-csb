from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from google.cloud import retail_v2
import os

app = FastAPI()

# Set up project and placement from environment or default
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT") or os.environ.get("PROJECT_ID")
CATALOG_ID = os.environ.get("CATALOG_ID", "default_catalog")
LOCATION = os.environ.get("LOCATION", "global")
PLACEMENT = f"projects/{PROJECT_ID}/locations/{LOCATION}/catalogs/{CATALOG_ID}/placements/default_search"

@app.get("/search")
def search(query: str = Query(..., description="Search query string")):
    client = retail_v2.SearchServiceClient()
    request = retail_v2.SearchRequest(
        placement=PLACEMENT,
        query=query,
        visitor_id="cloudrun-visitor"
    )
    response = client.search(request=request)
    # Convert protobuf response to dict for JSON serialization
    results = [retail_v2.SearchResponse.SearchResult.to_dict(r) for r in response.results]
    return JSONResponse(content={"results": results})

@app.get("/")
def root():
    return {"message": "Retail API Query Microservice. Use /search?query=your_query"}