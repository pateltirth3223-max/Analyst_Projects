-- Covid 19 Data Exploration

SELECT * 
FROM covisdeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Select Data that we are going to be starting with

SELECT continent, location, date, population, total_cases, total_deaths
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- Total Cases vs Total Deaths (Death Rate)
-- Shows likelihood of dying if you contract covid in a country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death Rate'
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location, date;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS 'Precentage of Population Infected'
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location, date;

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS DECIMAL(10,0))) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths AS DECIMAL(10,0))) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS DECIMAL(10,0))) AS total_deaths, SUM(CAST(new_deaths AS DECIMAL(10,0)))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY date;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT cd.iso_code, cd.continent, cd.location, cd.date, cd.population, cvacc.people_vaccinated, (cvacc.people_fully_vaccinated/cd.population)*100 AS 'Percentage of Population Vaccinated'
FROM coviddeaths AS cd
JOIN covidvaccinations AS cvacc
	ON cd.continent = cvacc.continent AND cd.location = cvacc.location AND cd.date = cvacc.date
WHERE cd.continent IS NOT NULL AND cvacc.continent IS NOT NULL;

-- Creating View to store data for later visualizations

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