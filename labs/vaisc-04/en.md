# **Personalizing Search Results with Vertex AI Search for Commerce**

## **What you'll learn**

In this lab, you will learn how to:

* Import product catalogs and user event data into Vertex AI Search for commerce.  
* Understand the data and time requirements for personalization models to become effective.  
* Articulate the difference between default semantic ranking and personalized ranking.  
* View and validate a serving configuration to ensure personalization is enabled.  
* Use the Evaluate tool to simulate and contrast non-personalized and personalized search queries.  
* Optionally apply a boosting control to influence search results with business rules.

## **Overview**

This lab will guide you through the process of providing the necessary data to enable personalized search results within Vertex AI Search for commerce. You will learn how to prepare and import data, verify configurations, and evaluate the impact of personalization.

Personalization elevates a search engine from a simple keyword matcher to an intelligent shopping assistant. By default, search results are ranked based on semantic relevance between the query and your product data. For personalization to work, you will need to provide a significant volume of high-quality user event data. The system's machine learning models will then require a period of time (potentially several days) to train on this data before personalized results become active.

To demonstrate this process, you will use the "Story of Jane," a sample use case that simulates a customer with a strong brand affinity. This lab will act as a 'dry run,' showing you the correct procedure and data format required. You will not see immediate personalization effects, but completing this lab will provide you with the foundational knowledge and a template for implementing personalization in your own projects.

## **Task 1. Enable Vertex AI Search for commerce and accept use terms**
Before you can begin using Vertex AI Search for commerce, you must enable the API and accept the terms of use.
1. In the Google Cloud console, on the **Navigation menu** (![Navigation menu](https://storage.googleapis.com/cloud-training/images/menu.png "Navigation menu")), click **View All Products**, then in **Artificial Intelligence** section, click **Search for Commerce**. Alternatively, you can search for "Search for Commerce" in the search bar at the top of the console. Direct link to the page: [Vertex AI Search for commerce](https://console.cloud.google.com/ai/retail/start).
2. Follow the prompts to enable the Vertex AI Search for commerce API and accept the terms of use. **Note:** DO NOT RUSH AFTER ACCEPTING THE TERMS OF USE. Wait for about 30 seconds before proceeding to the next step.
3. Turn on **Search & browse features** optional features.
4. Click **Get started** to navigate to the Search for commerce dashboard.

<ql-infobox>
<strong>Important:</strong> You might get an error message stating that the Search for commerce API is not enabled. (TBD: add screenshot of error message). Please wait for 10-15 minutes before you access the page. The error should clear up.
</ql-infobox>

<ql-infobox>
<strong>Important:</strong> You must wait for 5-10 minutes before data is imported by the Vertex AI Search for commerce service.
</ql-infobox>

## **Task 2. Data Import**

In this task, you will import the product catalog and the user event data that tells the "Story of Jane." Here is the product catalog data. Note the products belong to different brands - SummitStone and TrailBlazer.
```json
{  "id": "SKU-SS-BOOTS-01", 
   "title": "SummitStone Granite Hiking Boots", 
   "brands": ["SummitStone"], 
   "description": "Top-of-the-line, waterproof hiking boots with a 5-star rating. The most popular choice for serious hikers.", 
   "categories": ["Footwear", "Hiking Gear"], 
   "uri": "https://example.com/products/ss-boots-01", 
   "images": [{"uri": "https://storage.googleapis.com/artilekt-vaisc-csb_scripts/resources/images/SKU-SS-BOOTS-01-small.png"}], 
   "priceInfo": {"price": 199.99, "currencyCode": "USD"}, 
   "attributes": {"color": {"text": ["Granite Gray"]}, "waterproof": {"text": ["Yes"]}, "review_rating": {"numbers": [4.8]}}
}  
{  "id": "SKU-TB-BOOTS-02", 
   "title": "TrailBlazer All-Terrain Hiking Boots", 
   "brands": ["TrailBlazer"], 
   "description": "Reliable and comfortable all-terrain boots. A durable choice for any adventure.", 
   "categories": ["Footwear", "Hiking Gear"], 
   "uri": "https://example.com/products/tb-boots-02", 
   "images": [{"uri": "https://storage.googleapis.com/artilekt-vaisc-csb_scripts/resources/images/SKU-TB-BOOTS-02-small.png"}], 
   "priceInfo": {"price": 169.99, "currencyCode": "USD"}, 
   "attributes": {"color": {"text": ["Forest Green"]}, "waterproof": {"text": ["Yes"]}, "review_rating": {"numbers": [4.5]}}
}  
{  "id": "SKU-TB-BACKPACK-03", 
   "title": "TrailBlazer Expedition Backpack", 
   "brands": ["TrailBlazer"], 
   "description": "A 65L backpack perfect for multi-day trips. Built to last with the TrailBlazer guarantee.", 
   "categories": ["Packs", "Hiking Gear"], 
   "uri": "https://example.com/products/tb-backpack-03", 
   "images": [{"uri": "https://storage.googleapis.com/artilekt-vaisc-csb_scripts/resources/images/SKU-TB-BACKPACK-03-small.png"}], 
   "priceInfo": {"price": 249.99, "currencyCode": "USD"}, 
   "attributes": {"color": {"text": ["Red Clay"]}, "capacity_liters": {"numbers": [65]}, "review_rating": {"numbers": [4.6]}, "waterproof": {"text": ["No"]}}
}  
{  "id": "SKU-SS-TENT-04", 
   "title": "SummitStone 2-Person Dome Tent", 
   "brands": ["SummitStone"], 
   "description": "Lightweight and easy to set up, the SummitStone tent is ideal for weekend getaways.", 
   "categories": ["Tents", "Camping Gear"], 
   "uri": "https://example.com/products/ss-tent-04", 
   "images": [{"uri": "https://storage.googleapis.com/artilekt-vaisc-csb_scripts/resources/images/SKU-SS-TENT-04-small.png"}], 
   "priceInfo": {"price": 299.99, "currencyCode": "USD"}, 
   "attributes": {"color": {"text": ["Alpine Blue"]}, "capacity_persons": {"numbers": [2]}, "review_rating": {"numbers": [4.7]}, "waterproof": {"text": ["Yes"]}}
}
```
The user event data you will import simulates a customer named Jane who is a loyal customer of the "SummitStone" brand. Notice how the event history includes multiple touchpoints: she searches for the brand, views multiple products from the brand across different sessions, adds an item to her cart, and ultimately makes two separate purchases. Events like add-to-cart and especially purchase are very strong signals that the personalization engine will use to learn her brand preference.
```json
{  "eventType": "purchase", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-past-e4a1c"}, 
   "eventTime": "2025-05-22T17:35:51.147231Z", 
   "documents": [{"product": {"id": "SKU-SS-TENT-04"}, "quantity": 1}]
}
{  "eventType": "search", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-recent-f5b2d"}, 
   "eventTime": "2025-06-14T17:35:51.147275Z", 
   "searchQuery": "SummitStone gear"
}
{  "eventType": "detail-page-view", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-recent-f5b2d"}, 
   "eventTime": "2025-06-14T17:36:51.147280Z", 
   "documents": [{"product": {"id": "SKU-SS-TENT-04"}}]
}
{  "eventType": "detail-page-view", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-recent-f5b2d"}, 
   "eventTime": "2025-06-14T17:37:51.147283Z", 
   "documents": [{"product": {"id": "SKU-SS-BOOTS-01"}}]
}
{  "eventType": "add-to-cart", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-recent-f5b2d"}, 
   "eventTime": "2025-06-14T17:38:51.147285Z", 
   "documents": [{"product": {"id": "SKU-SS-BOOTS-01"}, "quantity": 1}]
}
{  "eventType": "purchase", 
   "user_info": {"userId": "user-jane-90210", "visitorId": "session-recent-f5b2d"}, 
   "eventTime": "2025-06-14T17:40:51.147287Z", 
   "documents": [{"product": {"id": "SKU-SS-BOOTS-01"}, "quantity": 1}]
}
```
You will import this data into Vertex AI Search for commerce next.

### **Import the Product Catalog**

1. In the Google Cloud Console, navigate to **Vertex AI Search for commerce**.  
2. From the left-hand navigation menu, click **Data**.  
3. On the **CATALOG** tab, click the main **IMPORT** button at the top.  
4. In the "Import Data" dialog that appears, configure the following:  
   * **Import type:** Select **Product Catalog**.  
   * **Source of data:** Select **Google Cloud Storage**.  
   * **Import branch:** Leave as the default branch.  
   * Google Cloud Storage location: `artilekt-vaisc-csb_scripts/resources/personalization/products.jsonl`
      <!-- <ql-code-block templated>
      {{{project_0.project_id|placeholder_project_id}}}_scripts/resources/personalization/products.jsonl
      </ql-code-block> -->
5. Click **IMPORT** and wait for the process to begin.

### **Import the User Events**

1. Click the **IMPORT** button again.  
2. In the "Import Data" dialog, configure the following:  
   * **Import type:** Select **User Events**.  
   * **Source of data:** Select **Google Cloud Storage**.  
   * Google Cloud Storage location: `artilekt-vaisc-csb_scripts/resources/personalization/user_events.jsonl`
      <!-- <ql-code-block templated>
      {{{project_0.project_id|placeholder_project_id}}}_scripts/resources/personalization/user_events.jsonl
      </ql-code-block> -->
3. Click **IMPORT**.

### **Validate the Data Import**

1. In the **Data** section, click on the **Import activity** tab.  
2. You will see the status of your two import jobs. After a few minutes, the status for both should change to **Succeeded**.  
3. Navigate back to the **CATALOG** tab. You should now see the four products from the sample file listed at the bottom of the page.

## **Task 3: Serving Configuration creation**

A serving configuration is a set of rules that determines how search results are delivered at runtime. It connects your product catalog to serving-time controls, such as personalization, faceting, and boosting. You will learn more about these in a later lab.

When you first enable the service and import data, a default\_search serving configuration is created automatically for you. By default, this configuration will already have the master switch for personalization enabled.

### **View the Default Serving Configuration**

1. From the left-hand navigation menu, click **Serving configs**.  
2. You will see a list of available configurations. Click on default\_search to view its details page.  
3. On the **DETAILS** tab, you will see several options. Confirm that the **Enable personalization** toggle is switched on. This ensures that once your personalization model is trained, this configuration will be ready to use it.

## **Task 4. Running a Search Query**

The **Evaluate** tool provides a sandbox environment where you can preview search results for different configurations without affecting your live website. You will use this tool to simulate two scenarios: a generic search that gets the default ranking, and a personalized search for Jane to see how her user history will eventually influence the results.

In a default search, results are ranked by semantic relevance. After the personalization models are trained, a personalized search for Jane will re-rank the results, boosting products from the "SummitStone" brand because the model will have learned her strong affinity from the user event data.

### **Run a Default Search Query**

1. From the left-hand navigation menu, click **Evaluate**.  
2. On the **SEARCH** tab, ensure the **Select serving config** dropdown is set to default\_search.  
3. In the "Search query" box, enter hiking boots.  
4. Ensure the **User ID** field is **empty**. This simulates a generic, non-personalized search.  
5. Click **SEARCH PREVIEW**.  
6. Observe the order of the results. You will likely see the "TrailBlazer" boots ranked first due to the model's default semantic interpretation.

### **Run a Personalized Search Query**

1. Keep the search query as hiking boots.  
2. In the **User ID** box, enter Jane's specific ID: user-jane-90210.  
3. Click **SEARCH PREVIEW**.  
4. Observe the results. Once the personalization models have had sufficient time to train on the data you imported (which can take several days), you will see the "SummitStone Granite Hiking Boots" boosted to the \#1 position in this view. This change is the direct result of the model applying Jane's learned brand preference to the search results.

## **Task 5. BONUS: Configuring Boosting control**

In addition to personalization, you can influence search ranking with business rules using serving controls. A boosting control allows you to immediately increase the ranking score of products that match certain criteria, without waiting for a model to train. A best practice for testing new rules is to create a separate serving configuration. This allows you to compare the results of the new config side-by-side with the default config.

Now, let's test a common business requirement. We will create a new serving config and a boosting control to demonstrate how you can strategically boost certain brands, for example, to align with a marketing promotion or a partnership agreement. This will also intentionally alter the default ranking where the 'TrailBlazer' brand appeared first.

### **Create a New Serving Configuration**

1. From the left-hand navigation menu, click **Serving configs**.  
2. Click **CREATE SERVING CONFIG** at the top.  
3. For **Select product**, choose **Search**.  
4. For **Serving config name**, enter boosted-search.  
5. Click **CONTINUE**.  
6. Leave the defaults on the next page (both toggles should be on) and click **CREATE**. You now have a duplicate of the default config that you can safely modify.

### **Create and Apply a Boosting Control**

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Boost SummitStone Brand  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Boost/bury controls**.  
4. Click **CONTINUE**. The UI will advance to the **Triggers** section.  
5. In the **Triggers** section, you define when this control should activate.  
   * Keep the default selection of **Search**. This means the control will apply when a user performs a search.  
   * Leave the optional "Partial match query terms" and "Exact match query terms" fields blank. This ensures the control applies to *all* search queries.  
   * Note that you could create a separate control and select **Browse categories** to influence the ranking on category pages. The setup process works in the same fashion.  
6. Click **CONTINUE**. The UI will advance to the **Actions** section.  
7. In the **Actions** section, configure a condition:  
   * **Condition type:** Select brands from the dropdown list.  
   * **Operator:** Leave as is any of.  
   * **Values:** Type SummitStone and press Enter.  
   * **Boost/bury value:** Drag the slider to a moderate positive value, such as 0.4.

**Note:** If your default search results in Task 4 already showed 'SummitStone' in the first position, you can demonstrate the opposite effect. Instead of boosting 'SummitStone', you can choose to 'bury' the 'TrailBlazer' brand. To do this, set the **Values** field to TrailBlazer and drag the **Boost/bury value** slider to a negative value, such as \-0.4. This will lower its ranking.

8. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
9. In the **Apply to serving configs** dropdown, check the box next to your new boosted-search config.  
10. Click **OK**, and then click **SUBMIT** to create and apply the control.

### **Compare Results Side-by-Side**

1. After the control has been created, navigate to the **Evaluate** page.  
2. First, confirm the baseline: select the default\_search config and search for hiking boots (with no User ID). You should see "TrailBlazer" ranked first.  
3. Next, change the serving config: select the boosted-search config from the dropdown menu and run the same search for hiking boots (with no User ID). You will now see the "SummitStone" boots ranked first, as the boosting control is giving them an immediate advantage.

This side-by-side comparison clearly isolates and demonstrates the effect of your new business rule.

## **Congratulations\!**

You have successfully completed the lab and have taken the first crucial steps toward delivering a personalized search experience. You learned how to import a product catalog and the correctly formatted user event data needed to tell a story. You also learned how to validate a serving configuration and use the Evaluate tool to contrast a default search with a personalized one, observing the powerful impact of user history on search results.

The sample product data, user event "story," and product images for this lab were generated by Gemini\!