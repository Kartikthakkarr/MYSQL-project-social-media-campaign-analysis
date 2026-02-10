drop database socialmedia;
create DATABASE socialmedia;
USE socialmedia;

DROP TABLE IF EXISTS campaign_data;

CREATE TABLE campaign_data (
  ad_id INT,
  xyz_campaign_id INT,
  fb_campaign_id INT,
  age VARCHAR(10),
  gender CHAR(1),
  interest INT,
  impressions INT,
  clicks INT,
  spent DECIMAL(10,2),
  total_conversion INT,
  approved_conversion INT,
  conversion_rate DECIMAL(6,2),
  cpm DECIMAL(10,2),
  cpc DECIMAL(10,2),
  ctr DECIMAL(6,2),
  cpa DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sql project.csv'
INTO TABLE campaign_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  ad_id,
  xyz_campaign_id,
  fb_campaign_id,
  age,
  gender,
  interest,
  Impressions,
  Clicks,
  @Spent,
  Total_Conversion,
  Approved_Conversion,
  @Conversion_rate,
  @CPM,
  @CPC,
  @CTR,
  @CPA
)
SET
  Spent = NULLIF(REPLACE(REPLACE(@Spent, '$', ''), ',', ''), ''),
  Conversion_rate = NULLIF(REPLACE(@Conversion_rate, '%', ''), ''),
  CPM = NULLIF(REPLACE(REPLACE(@CPM, '$', ''), ',', ''), ''),
  CPC = NULLIF(REPLACE(REPLACE(@CPC, '$', ''), ',', ''), ''),
  CTR = NULLIF(REPLACE(@CTR, '%', ''), ''),
  CPA = NULLIF(REPLACE(REPLACE(@CPA, '$', ''), ',', ''), '');
  
  select count(*) from campaign_data;
  
  select * from campaign_data;

 /*1 . Which age group generated the highest total ad impressions across all campaigns."*/
   
   SELECT age,
       SUM(impressions) AS total_impressions
FROM campaign_data
GROUP BY age
ORDER BY total_impressions DESC;

/*2. Which gender produced the maximum number of total clicks?*/

SELECT gender,
       SUM(clicks) AS total_clicks
FROM campaign_data
GROUP BY gender
ORDER BY total_clicks DESC;

/*3.Which campaign had the highest total advertising spend?*/

SELECT xyz_campaign_id,
       SUM(spent) AS total_spent
FROM campaign_data
GROUP BY xyz_campaign_id
ORDER BY total_spent DESC;

/*4.Which ad has the lowest cost per click (CPC), indicating the most cost-efficient ad?*/

SELECT ad_id, cpc
FROM campaign_data
ORDER BY cpc ASC
 limit 1;
 
 /*5.What is the total number of approved conversions generated from all social media campaigns combined?*/

SELECT SUM(approved_conversion) AS total_approved_conversions
FROM campaign_data;

/*6. Which age and gender combination has the highest conversion rate (approved conversions per click)?*/

SELECT age,
       gender,
       AVG(approved_conversion / NULLIF(clicks, 0)) AS conversion_rate
FROM campaign_data
GROUP BY age, gender
ORDER BY conversion_rate DESC
limit 1;

/*7.Which interest category resulted in the maximum total approved conversions?*/

SELECT interest,
       SUM(approved_conversion) AS total_conversions
FROM campaign_data
GROUP BY interest
ORDER BY total_conversions DESC
LIMIT 1;

/*8.Which campaign achieved the highest number of conversions, while also keeping the spend as low as possible?*/

SELECT fb_campaign_id,
       SUM(approved_conversion) AS conversions,
       SUM(spent) AS total_spent
FROM campaign_data
GROUP BY fb_campaign_id
ORDER BY conversions DESC, total_spent ASC
LIMIT 1;

/*9.Which ads received clicks but failed to generate any approved conversions, indicating poor landing page or targeting performance?*/

SELECT ad_id, clicks, approved_conversion
FROM campaign_data
WHERE clicks > 0
  AND approved_conversion = 0;
  
  /*10.Which age group has the highest average Click-Through Rate (CTR), showing better engagement?*/
  
SELECT age,
       AVG(ctr) AS avg_ctr
FROM campaign_data
GROUP BY age
ORDER BY avg_ctr DESC
LIMIT 1;  

/*11. Which campaigns are underperforming, defined as:
- High total spend  
- Low conversions  
- Higher than average cost per acquisition (CPA)*/
SELECT xyz_campaign_id,
       SUM(spent) AS total_spent,
       SUM(approved_conversion) AS total_conversions,
       AVG(cpa) AS avg_cpa
FROM campaign_data
GROUP BY xyz_campaign_id
HAVING total_spent > 10
   AND total_conversions < 1
   AND avg_cpa > (
       SELECT AVG(cpa) FROM campaign_data
   );

/*12.Which age, gender, and interest combination delivers the lowest average CPA, making it the most cost-effective audience segment?*/
   
SELECT age, gender, interest,
       AVG(cpa) AS avg_cpa
FROM campaign_data
GROUP BY age, gender, interest
ORDER BY avg_cpa ASC
LIMIT 1;

/*13.Which ads have above-average impressions but below-average CTR, indicating visibility without engagement?*/

SELECT ad_id, impressions, ctr
FROM campaign_data
WHERE impressions > (
        SELECT AVG(impressions)
        FROM campaign_data
      )
  AND ctr < (
        SELECT AVG(ctr)
        FROM campaign_data
      );

/*14. Which ads perform efficiently, having:
- Lower than average CPA  
- More than 5 approved conversions?
*/
      
SELECT ad_id,
       approved_conversion,
       cpa,
       ctr
FROM campaign_data
WHERE cpa < (
        SELECT AVG(cpa)
        FROM campaign_data
      )
  AND approved_conversion > 5
ORDER BY approved_conversion DESC;  

/*15.Which interest category has the highest conversion efficiency (approved conversions per click), making it the most valuable audience?*/

SELECT interest,
       SUM(approved_conversion) / NULLIF(SUM(clicks), 0) AS conversion_efficiency
FROM campaign_data
GROUP BY interest
ORDER BY conversion_efficiency DESC
LIMIT 1;  

/*16.Rank all campaigns based on their Click-Through Rate (CTR) to identify which campaign performed best in generating clicks from impressions.*/

SELECT
  xyz_campaign_id,
  clicks,
  impressions,
  ROUND((clicks / impressions) * 100, 2) AS ctr_percent,
  RANK() OVER (ORDER BY (clicks / impressions) DESC) AS ctr_rank
FROM campaign_data;

/*17.Which campaigns are the Top 3 best performers based on CTR (Click Through Rate)?*/

SELECT *
FROM (
  SELECT
    xyz_campaign_id,
    clicks,
    impressions,
    ROUND((clicks / impressions) * 100, 2) AS ctr_percent,
    RANK() OVER (ORDER BY (clicks / impressions) DESC) AS ctr_rank
  FROM campaign_data
) x
WHERE ctr_rank <= 3;





  


  
  
  