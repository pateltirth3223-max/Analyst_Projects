
-- Extracting and Storing Data Used for Visulization

CREATE OR REPLACE VIEW Visualization_Data AS
SELECT cd.iso_code, cd.continent, cd.location, cd.date, cd.population,
cd.total_cases, (cd.total_cases/cd.population)*100 AS 'Precentage of Population Infected', 
cd.total_deaths, (cd.total_deaths/cd.total_cases)*100 AS 'Death Rate', (cd.total_deaths/cd.population)*100 AS 'Percentage Population Dead',
cvacc.people_vaccinated, (cvacc.people_fully_vaccinated/cd.population)*100 AS 'Percentage of Population Vaccinated',
cd.population_density, cd.median_age, cd.human_development_index
FROM coviddeaths AS cd
JOIN covidvaccinations AS cvacc
	ON cd.continent = cvacc.continent AND cd.location = cvacc.location AND cd.date = cvacc.date
WHERE cd.continent IS NOT NULL AND cvacc.continent IS NOT NULL
WITH CASCADED CHECK OPTION;