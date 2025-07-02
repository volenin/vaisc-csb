# **Implementing Advanced Search Features - UI version**

## **What you'll learn**

In this lab, you will learn how to:

* Enable Vertex AI Search for commerce API and accept terms of use
* Import product catalog and user event data into Vertex AI Search for commerce
* Create and configure serving configurations for advanced search functionality
* Implement boosting controls to influence search ranking based on business rules
* Set up redirect controls to guide users to specific pages for targeted search terms
* Create synonym controls to improve search comprehension and broaden results
* Use product pinning to promote specific items in search results
* Configure replacement controls to suppress irrelevant search terms
* Apply filter controls to refine search results based on specific conditions
* Evaluate and compare different search configurations side-by-side

## **Overview**

In this lab, you will implement advanced search features using Vertex AI Search for commerce through the Google Cloud Console UI. You'll start by enabling the service and importing sample product catalog data along with user event data that simulates customer behavior patterns. 

The lab focuses on configuring various search controls to enhance the user experience and align search results with business objectives. You'll work with hiking and camping gear products from two fictional brands (SummitStone and TrailBlazer) and learn how to influence search ranking through boosting controls, redirect users for specific brand searches, create synonyms to improve search comprehension, pin important products to top positions, suppress irrelevant terms, and filter results based on categories.

Throughout the lab, you'll use the Google Cloud Console's evaluation tools to test and compare different configurations, demonstrating how each control affects search behavior. By the end of this lab, you'll have hands-on experience with the key features that make search experiences more relevant, personalized, and business-aligned.

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
   * Google Cloud Storage location: Use `Browse` button and navigate to `<project_id>_retail/resources/personalization/products.jsonl`
      <!-- <ql-code-block templated>
      {{{project_0.project_id|placeholder_project_id}}}_scripts/resources/personalization/products.jsonl
      </ql-code-block> -->
5. Click **IMPORT** and wait for the process to begin.

### **Import the User Events**

1. Click the **IMPORT** button again.  
2. In the "Import Data" dialog, configure the following:  
   * **Import type:** Select **User Events**.  
   * **Source of data:** Select **Google Cloud Storage**.  
   * Google Cloud Storage location: Use `Browse` button and navigate to `<project_id>_retail/resources/personalization/user_events.jsonl`
      <!-- <ql-code-block templated>
      {{{project_0.project_id|placeholder_project_id}}}_scripts/resources/personalization/user_events.jsonl
      </ql-code-block> -->
3. Click **IMPORT**.

### **Validate the Data Import**

1. In the **Data** section, click on the **Import activity** tab.  
2. You will see the status of your two import jobs. After a few minutes, the status for both should change to **Succeeded**.  
3. Navigate back to the **CATALOG** tab. You should now see the four products from the sample file listed at the bottom of the page.

## **Task 3. Configuring Boosting control**

You can influence search ranking with business rules using serving controls. A boosting control allows you to immediately increase the ranking score of products that match certain criteria, without waiting for a model to train. A best practice for testing new rules is to create a separate serving configuration. This allows you to compare the results of the new config side-by-side with the default config.

Now, let's test a common business requirement. We will create a new serving config and a boosting control to demonstrate how you can strategically boost certain brands, for example, to align with a marketing promotion or a partnership agreement. This will also intentionally alter the default ranking where the 'TrailBlazer' brand appeared first.

### **Create a New Serving Configuration**

1. From the left-hand navigation menu, click **Serving configs**.  
2. Click **CREATE SERVING CONFIG** at the top.  
3. For **Select product**, choose **Search**.  
4. For **Serving config name**, enter `advanced_search`.  
5. Click **CONTINUE**.  
6. Leave the defaults on the next page (both toggles should be on) and click **CREATE**. You now have a duplicate of the default config that you can safely modify.

### **Create and Apply a Boosting Control**

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** `Boost SummitStone Brand`
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
   * **Values:** Type `"SummitStone"` and press Enter.  
   * **Boost/bury value:** Drag the slider to a moderate positive value, such as 0.4.

**Note:** If your default search results in Task 4 already showed 'SummitStone' in the first position, you can demonstrate the opposite effect. Instead of boosting 'SummitStone', you can choose to 'bury' the 'TrailBlazer' brand. To do this, set the **Values** field to TrailBlazer and drag the **Boost/bury value** slider to a negative value, such as \-0.4. This will lower its ranking.

8. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
9. In the **Apply to serving configs** dropdown, check the box next to your new `advanced_search` config.  
10. Click **OK**, and then click **SUBMIT** to create and apply the control.

### **Compare Results Side-by-Side**

1. After the control has been created, navigate to the **Evaluate** page.  
2. First, confirm the baseline: select the default\_search config and search for hiking boots (with no User ID). You should see "TrailBlazer" ranked first.  
3. Next, change the serving config: select the `advanced_search` config from the dropdown menu and run the same search for hiking boots (with no User ID). You will now see the "SummitStone" boots ranked first, as the boosting control is giving them an immediate advantage.

This side-by-side comparison clearly isolates and demonstrates the effect of your new business rule.

You will now proceed to configure other advanced features, such as redirect control and others, to further enhance the search experience. You will be applying these features to the same `advanced_search` serving configuration you just created, allowing you to build on top of it without affecting the default search experience. Use the same process for validating and evaluating the results.

## **Task 4. Configure Redirect control**

A redirect control is useful for guiding users to a specific page when they search for certain terms. In this task, you will create a control to redirect any search query containing "adidas" to the adidas homepage. This is a common requirement for handling brand searches or specific promotional campaigns.

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Redirect Adidas Search  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Redirect controls**.  
4. Click **CONTINUE**. The UI will advance to the **Triggers** section.  
5. In the **Triggers** section, you define when this control should activate.  
   * Keep the default selection of **Search**. This means the control will apply when a user performs a search.  
   * In the **Exact match query terms** field, type adidas and press Enter. This ensures the control only activates when a user searches for that specific term.  
6. Click **CONTINUE**. The UI will advance to the **Actions** section.  
7. In the **Actions** section, configure the redirect destination:  
   * In the **Redirect URI** field, enter http://adidas.com.  
8. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
9. In the **Apply to serving configs** dropdown, check the box next to the serving config you want to apply this redirect to (`advanced_config`).  
10. Click **OK**, and then click **SUBMIT** to create and apply the control.


## **Task 5. Create Synonym entry**

Synonyms help the search engine understand user intent better by treating different words as equivalent. In this task, you will create a two-way synonym between "camping" and "travel." This will ensure that a search for "travel gear" also returns relevant "camping" equipment, and vice-versa, broadening the search results.

1.  From the left-hand navigation menu, click **Controls**.
2.  On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.
3.  In the **Preferences** section, configure the following:
    *   **Control name:** `Camping-Travel Synonym`
    *   **Product selection:** Select **Search & Browse**.
    *   **Control Type:** Select **Two-way Synonym Control**.
4.  Click **CONTINUE**. The UI will advance to the **Actions** section.
5.  In the **Actions** section, enter the terms for the synonym group:
    *   In the **Terms** field, type `camping` and press Enter.
    *   In the same field, type `travel` and press Enter. Both terms should appear as chips in the input box.
6.  Click **CONTINUE**. The UI will advance to the **Serving Configs** section.
7.  In the **Apply to serving configs** dropdown, check the box next to your `advanced_search` config.
8.  Click **OK**, and then click **SUBMIT** to create the control.
9.  To test, navigate to the **Evaluate** page, select the `advanced_search` config, and search for `travel gear`. The results should now include camping-related items, such as the "SummitStone 2-Person Dome Tent."

## **Task 5\. Create a Synonym Entry**

A two-way synonym control helps broaden search results by treating different terms as equivalent. For example, if a user searches for "camping," they will also see results for "travel," and vice-versa. This is useful for capturing user intent when multiple terms can describe the same product category.

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Synonym Camping Travel  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Two-way Synonym Control**.  
4. Click **CONTINUE**. The UI will advance to the **Actions** section.  
5. In the **Actions** section, enter the terms for the synonym group:  
   * In the **Terms** field, type camping and press Enter.  
   * In the same field, type travel and press Enter. Both terms should appear as chips in the input box.  
6. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
7. In the **Apply to serving configs** dropdown, check the box next to the serving config you want to apply this control to (for example, advanced\_search).  
8. Click **OK**, and then click **SUBMIT** to create the control.

***Note on Synonym Types:***

* **Two-Way Synonyms (as used above):** The relationship is reciprocal. A search for "camping" will show "travel" results, and a search for "travel" will show "camping" results.  
* **One-Way Synonyms:** The relationship is directional. For example, you could make "jeans" a one-way synonym for "pants". A search for "pants" would then also return results for "jeans", but a search for "jeans" would *not* show other types of pants. This is useful for mapping specific terms to broader categories.

## **Task 6\. Pin a Specific Product**

Product pinning allows you to manually place a specific item at a fixed position in the search or browse results. This is a powerful tool for promoting new arrivals, best-sellers, or items from a specific campaign. In this task, you will pin the 'TrailBlazer Expedition Backpack' to the very first position for all searches.

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Pin TrailBlazer Backpack  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Product pinning controls**.  
4. Click **CONTINUE**. The UI will advance to the **Triggers** section.  
5. In the **Triggers** section, leave the fields blank to apply this pinning control to all search and browse pages.  
6. Click **CONTINUE**. The UI will advance to the **Actions** section.  
7. In the **Actions** section, configure the product and position:  
   * **Item ID:** Enter the product's Item ID, for example SKU-TB-BACKPACK-03.  
   * **Position:** Enter 1\.  
8. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
9. In the **Apply to serving configs** dropdown, check the box next to the serving config where you want this pinning rule to be active (for example, advanced\_search).  
10. Click **OK**, and then click **SUBMIT** to create and apply the control.

## **Task 7\. Suppress a Search Term**

You can use the **Replacement Control** to completely suppress, or remove, a term from a user's query. This is done by replacing the term with an empty value. This is useful for filtering out generic, subjective, or irrelevant words (like "sturdy," "nice," or "best") that don't help narrow down product results effectively. If a user includes a suppressed term in their query, the search behaves as if the word was never typed.

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Suppress Mountain Boots  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Replacement Control**.  
4. Click **CONTINUE**. The UI will advance to the **Actions** section.  
5. In the **Actions** section, specify the term to suppress:  
   * **Query term:** Enter mountain boots.  
   * **Replacement:** Leave this field blank.  
6. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
7. In the **Apply to serving configs** dropdown, check the box next to the serving config you want to apply this control to (for example, advanced\_search).  
8. Click **OK**, and then click **SUBMIT** to create the control.

## **Task 8\. Filter Search Results**

A filter control allows you to show or hide certain products based on specific conditions when a user performs a search. This is useful for refining results and ensuring relevance. In this task, you will create a control that prevents items from the 'Footwear' category from appearing when a user searches for 'camping gear'.

1. From the left-hand navigation menu, click **Controls**.  
2. On the **SERVING CONTROLS** tab, click **CREATE CONTROL**.  
3. In the **Preferences** section, configure the following:  
   * **Control name:** Camping gear footwear suppression  
   * **Product selection:** Select **Search & Browse**.  
   * **Control Type:** Select **Filter controls**.  
4. Click **CONTINUE**. The UI will advance to the **Triggers** section.  
5. In the **Triggers** section, define when this control should activate:  
   * Select **Search**.  
   * In the **Exact match query terms** field, type camping gear and press Enter.  
6. Click **CONTINUE**. The UI will advance to the **Actions** section.  
7. In the **Actions** section, define the filter condition:  
   * **Condition Type:** Select categories.  
   * **Operator:** Select is not any of.  
   * **Values:** Type Footwear and press Enter.  
8. Click **CONTINUE**. The UI will advance to the **Serving Configs** section.  
9. In the **Apply to serving configs** dropdown, check the box next to advanced\_search.  
10. Click **OK**, and then click **SUBMIT** to create the control.

## **Congratulations\!**

You have successfully completed the lab and have taken the first crucial steps toward delivering a personalized search experience. You learned how to import a product catalog and the correctly formatted user event data needed to tell a story. You also learned how to validate a serving configuration and use the Evaluate tool to contrast a default search with a personalized one, observing the powerful impact of user history on search results.

The sample product data, user event "story," and product images for this lab were generated by Gemini\!