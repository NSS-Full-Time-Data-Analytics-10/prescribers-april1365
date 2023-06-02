---Q1a 
SELECT prescriber.npi, total_claim_count 
FROM prescriber FULL JOIN prescription ON prescriber.npi = prescription.npi
WHERE total_claim_count_ge65 IS NOT NULL
ORDER BY total_claim_count DESC;

---Q1b 
SELECT total_claim_count, nppes_provider_last_org_name AS last_name, nppes_provider_first_name AS first_name, specialty_description 
FROM prescriber FULL JOIN prescription ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT NULL
ORDER BY total_claim_count DESC;

---Q2a family practice
SELECT specialty_description, SUM(total_claim_count) AS total_claim_count
FROM prescriber FULL JOIN prescription ON prescriber.npi = prescription.npi
WHERE total_claim_count IS NOT NULL
GROUP BY specialty_description
ORDER BY total_claim_count DESC;

---Q2b nurse practitioner
SELECT specialty_description, total_claim_count
FROM prescriber FULL JOIN prescription ON prescriber.npi = prescription.npi
				FULL JOIN drug ON drug.drug_name = prescription.drug_name
WHERE opioid_drug_flag = 'Y';

---Q3a pirifenidone
SELECT generic_name, total_drug_cost
FROM prescription FULL join drug USING(drug_name)
WHERE total_drug_cost IS NOT NULL
ORDER BY total_drug_cost DESC;

---Q3b c1 esterase inhibitor
SELECT generic_name, ROUND(SUM(total_drug_cost)/SUM(total_day_supply),2) AS cost_per_day
FROM prescription FULL join drug USING(drug_name)
WHERE total_drug_cost IS NOT NULL
GROUP BY generic_name
ORDER BY cost_per_day DESC;

---Q4a
SELECT drug_name,
CASE WHEN opioid_drug_flag LIKE 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag LIKE 'Y' THEN 'antibiotic'
	 ELSE 'neither' END AS drug_type
FROM drug;

---Q4b neither
SELECT SUM(total_drug_cost)::money AS total_cost,
CASE WHEN opioid_drug_flag LIKE 'Y' THEN 'opioid'
	 WHEN antibiotic_drug_flag LIKE 'Y' THEN 'antibiotic'
	 ELSE 'neither' END AS drug_type
FROM drug FULL JOIN prescription USING(drug_name)
GROUP BY drug_type
ORDER BY total_cost DESC;

---Q5a 10
SELECT cbsa
FROM cbsa
WHERE cbsaname LIKE '%TN%'
GROUP BY cbsa;

---Q5b largest/Nash-Dav-Murf-Frank 1830410-smallest/Morristown 116352
SELECT cbsa, cbsaname, SUM(population) AS population
FROM cbsa FULL JOIN population USING(fipscounty)
WHERE population IS NOT NULL AND cbsa IS NOT NULL
GROUP by cbsa, cbsaname
ORDER BY population DESC;

---Q5c largest county not included in cbsa
---Sevier 95523
SELECT cbsa, cbsaname, county, SUM(population) AS population
FROM cbsa FULL JOIN fips_county USING(fipscounty)
		  FULL JOIN population USING(fipscounty)
WHERE population IS NOT NULL 
GROUP by cbsa, cbsaname, county
ORDER BY population DESC;

---Q6a total claims at least 3000
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

---Q6b opioid or not 
SELECT drug_name, total_claim_count,
CASE WHEN opioid_drug_flag ='Y' THEN 'opioid'
ELSE 'not opioid' END AS category
FROM prescription INNER JOIN drug USING(drug_name)
WHERE total_claim_count >= 3000
ORDER BY total_claim_count DESC;

---Q6c
SELECT drug_name, total_claim_count, opioid_drug_flag AS opioid, nppes_provider_last_org_name AS last_name, nppes_provider_first_name AS first_name
FROM prescription FULL JOIN drug USING(drug_name) 
FULL JOIN prescriber USING(npi)
WHERE total_claim_count >= 3000
AND opioid_drug_flag = 'Y';

---Q7a
SELECT nppes_provider_last_org_name, drug_name
FROM prescriber 
CROSS JOIN drug
WHERE specialty_description LIKE 'Pain Management' AND opioid_drug_flag ='Y' AND nppes_provider_city ILIKE 'Nashville';

---Q7b
SELECT SUM(total_claim_count), npi, drug.drug_name
FROM prescriber
CROSS join drug
FULL JOIN prescription using(npi, drug_name)
WHERE specialty_description LIKE 'Pain Management' AND opioid_drug_flag ='Y' AND nppes_provider_city ILIKE 'Nashville'
GROUP BY npi, drug.drug_name
ORDER BY SUM(total_claim_count) DESC NULLS LAST;

---Q7c
SELECT npi, drug.drug_name,
COALESCE(SUM(total_claim_count), '0') AS sum
FROM prescriber CROSS JOIN drug
FULL JOIN prescription using(npi, drug_name)
WHERE specialty_description LIKE 'Pain Management' AND opioid_drug_flag ='Y' AND nppes_provider_city ILIKE 'Nashville'
GROUP BY npi, drug.drug_name
ORDER BY SUM(total_claim_count) DESC;

---Bonus 1
SELECT 
(SELECT COUNT(DISTINCT npi)
FROM prescriber) -
(SELECT COUNT(DISTINCT npi)
FROM prescription);

---Bonus 2a
SELECT COUNT(generic_name), generic_name
FROM drug INNER JOIN prescription USING(drug_name)
		  INNER JOIN prescriber USING(npi)
WHERE specialty_description LIKE 'Family Practice'
GROUP BY generic_name
ORDER BY COUNT(generic_name) DESC
LIMIT 5;
