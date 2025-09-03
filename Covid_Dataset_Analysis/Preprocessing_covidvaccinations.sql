-- Step 1: Update all empty strings to NULL for numeric columns
UPDATE CovidVaccinations SET new_tests = NULL WHERE new_tests = '';
UPDATE CovidVaccinations SET total_tests = NULL WHERE total_tests = '';
UPDATE CovidVaccinations SET total_tests_per_thousand = NULL WHERE total_tests_per_thousand = '';
UPDATE CovidVaccinations SET new_tests_per_thousand = NULL WHERE new_tests_per_thousand = '';
UPDATE CovidVaccinations SET new_tests_smoothed = NULL WHERE new_tests_smoothed = '';
UPDATE CovidVaccinations SET new_tests_smoothed_per_thousand = NULL WHERE new_tests_smoothed_per_thousand = '';
UPDATE CovidVaccinations SET positive_rate = NULL WHERE positive_rate = '';
UPDATE CovidVaccinations SET tests_per_case = NULL WHERE tests_per_case = '';
UPDATE CovidVaccinations SET total_vaccinations = NULL WHERE total_vaccinations = '';
UPDATE CovidVaccinations SET people_vaccinated = NULL WHERE people_vaccinated = '';
UPDATE CovidVaccinations SET people_fully_vaccinated = NULL WHERE people_fully_vaccinated = '';
UPDATE CovidVaccinations SET new_vaccinations = NULL WHERE new_vaccinations = '';
UPDATE CovidVaccinations SET new_vaccinations_smoothed = NULL WHERE new_vaccinations_smoothed = '';
UPDATE CovidVaccinations SET total_vaccinations_per_hundred = NULL WHERE total_vaccinations_per_hundred = '';
UPDATE CovidVaccinations SET people_vaccinated_per_hundred = NULL WHERE people_vaccinated_per_hundred = '';
UPDATE CovidVaccinations SET people_fully_vaccinated_per_hundred = NULL WHERE people_fully_vaccinated_per_hundred = '';
UPDATE CovidVaccinations SET new_vaccinations_smoothed_per_million = NULL WHERE new_vaccinations_smoothed_per_million = '';
UPDATE CovidVaccinations SET stringency_index = NULL WHERE stringency_index = '';
UPDATE CovidVaccinations SET population_density = NULL WHERE population_density = '';
UPDATE CovidVaccinations SET median_age = NULL WHERE median_age = '';
UPDATE CovidVaccinations SET aged_65_older = NULL WHERE aged_65_older = '';
UPDATE CovidVaccinations SET aged_70_older = NULL WHERE aged_70_older = '';
UPDATE CovidVaccinations SET gdp_per_capita = NULL WHERE gdp_per_capita = '';
UPDATE CovidVaccinations SET extreme_poverty = NULL WHERE extreme_poverty = '';
UPDATE CovidVaccinations SET cardiovasc_death_rate = NULL WHERE cardiovasc_death_rate = '';
UPDATE CovidVaccinations SET diabetes_prevalence = NULL WHERE diabetes_prevalence = '';
UPDATE CovidVaccinations SET female_smokers = NULL WHERE female_smokers = '';
UPDATE CovidVaccinations SET male_smokers = NULL WHERE male_smokers = '';
UPDATE CovidVaccinations SET handwashing_facilities = NULL WHERE handwashing_facilities = '';
UPDATE CovidVaccinations SET hospital_beds_per_thousand = NULL WHERE hospital_beds_per_thousand = '';
UPDATE CovidVaccinations SET life_expectancy = NULL WHERE life_expectancy = '';
UPDATE CovidVaccinations SET human_development_index = NULL WHERE human_development_index = '';

-- Step 2: Modify column data types to appropriate numeric types
-- Large integer values (tests, vaccinations)
ALTER TABLE CovidVaccinations MODIFY new_tests BIGINT;
ALTER TABLE CovidVaccinations MODIFY total_tests BIGINT;
ALTER TABLE CovidVaccinations MODIFY total_vaccinations BIGINT;
ALTER TABLE CovidVaccinations MODIFY people_vaccinated BIGINT;
ALTER TABLE CovidVaccinations MODIFY people_fully_vaccinated BIGINT;
ALTER TABLE CovidVaccinations MODIFY new_vaccinations BIGINT;
ALTER TABLE CovidVaccinations MODIFY new_vaccinations_smoothed BIGINT;

-- Decimal values (rates, percentages, per capita measures)
ALTER TABLE CovidVaccinations MODIFY total_tests_per_thousand DECIMAL(10,2);
ALTER TABLE CovidVaccinations MODIFY new_tests_per_thousand DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY new_tests_smoothed DECIMAL(12,2);
ALTER TABLE CovidVaccinations MODIFY new_tests_smoothed_per_thousand DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY positive_rate DECIMAL(6,4);
ALTER TABLE CovidVaccinations MODIFY tests_per_case DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY total_vaccinations_per_hundred DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY people_vaccinated_per_hundred DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY people_fully_vaccinated_per_hundred DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY new_vaccinations_smoothed_per_million DECIMAL(10,2);
ALTER TABLE CovidVaccinations MODIFY stringency_index DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY population_density DECIMAL(10,2);
ALTER TABLE CovidVaccinations MODIFY median_age DECIMAL(4,1);
ALTER TABLE CovidVaccinations MODIFY aged_65_older DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY aged_70_older DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY gdp_per_capita DECIMAL(12,2);
ALTER TABLE CovidVaccinations MODIFY extreme_poverty DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY cardiovasc_death_rate DECIMAL(8,2);
ALTER TABLE CovidVaccinations MODIFY diabetes_prevalence DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY female_smokers DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY male_smokers DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY handwashing_facilities DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY hospital_beds_per_thousand DECIMAL(6,2);
ALTER TABLE CovidVaccinations MODIFY life_expectancy DECIMAL(5,2);
ALTER TABLE CovidVaccinations MODIFY human_development_index DECIMAL(5,3);

-- Step 3: Ensure text columns have appropriate data types
ALTER TABLE CovidVaccinations MODIFY iso_code VARCHAR(10);
ALTER TABLE CovidVaccinations MODIFY continent VARCHAR(50);
ALTER TABLE CovidVaccinations MODIFY location VARCHAR(100);
ALTER TABLE CovidVaccinations MODIFY tests_units VARCHAR(50);