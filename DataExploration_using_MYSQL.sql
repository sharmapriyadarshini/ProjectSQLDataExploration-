USE PortfolioProject;

/*
Project: COVID-19 Data Exploration
Description: This project aims to perform in-depth exploration and analysis of COVID-19 related data, specifically focusing on vaccination and death statistics. 
The provided datasets include information on vaccination rates, testing, population density, and mortality.
Goals:
1. Analyze vaccination progress and coverage across different locations.
2. Examine the relationship between vaccination rates and COVID-19 mortality.
3. Identify trends in new cases, deaths, and testing rates over time.
4. Investigate factors such as population density, testing units, and health indicators.
Datasets:
- covid_vaccinations: Contains data related to COVID-19 vaccinations, including total vaccinations, people vaccinated, and booster doses.
- covid_deaths: Provides information about COVID-19 deaths, including total deaths, new cases, and population details.
Methods: Utilizing SQL queries, I will aggregate, filter, and visualize the data to gain insights into the progression of the pandemic, vaccination efforts, and potential correlations.
*/
 
-- Getting a general overview of the available data
SELECT 
    COUNT(*) AS TotalRows,
    MIN(date) AS MinDate,
    MAX(date) AS MaxDate
FROM
    covid_deaths;

-- Calculating the total cases and deaths:
SELECT 
    SUM(total_cases) AS TotalCases,
    SUM(total_deaths) AS TotalDeaths
FROM
    covid_deaths;

-- Calculating case and death rates:
SELECT 
    date,
    location,
    total_cases / population AS CaseRate,
    total_deaths / population AS DeathRate
FROM
    covid_deaths;


-- Analyzing new cases and deaths:
SELECT 
    location, date, new_cases, new_deaths
FROM
    covid_deaths
WHERE
    new_cases > 0 OR new_deaths > 0;

-- Examining testing and positive rates:
SELECT 
    location, total_tests, positive_rate
FROM
    covid_vaccinations;

-- Looking into life expectancy and health factors:
SELECT 
    location,
    life_expectancy,
    hospital_beds_per_thousand,
    male_smokers,
    female_smokers
FROM
    covid_vaccinations;

-- Exploring possible correlation between vaccinations and deaths:
SELECT 
    V.date, V.location, V.total_vaccinations, D.total_deaths
FROM
    covid_vaccinations V
        JOIN
    covid_deaths D ON V.location = D.location
        AND V.date = D.date;

-- This query will return all rows and columns from the covid_deaths table that match the given conditions
SELECT 
    *
FROM
    PortfolioProject.covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 3 , 4;

-- retrieving all columns from the covid_vaccinations table and sorting the results
SELECT 
    *
FROM
    PortfolioProject.covid_vaccinations
ORDER BY 3 , 4;

/* UPDATE covid_deaths
SET total_cases = NULL
WHERE total_cases = ''; */

-- Fetching information about COVID-19 cases and deaths
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    PortfolioProject.covid_deaths
WHERE
    continent IS NOT NULL
ORDER BY 1 , 2;


-- Total Cases vs Total Deaths
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (Total_deaths / total_cases) * 100 AS Death_Percentage
FROM
    PortfolioProject.covid_deaths
WHERE
    location LIKE '%states%'
        AND continent IS NOT NULL
ORDER BY 1 , 2;


-- what percentage of COVID 
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS Death_Percentage
FROM
    PortfolioProject.covid_deaths
WHERE
    location LIKE '%states%'
ORDER BY 1 , 2;


-- Looking for companies with Highest Infection Rate compared to Population

SELECT 
    location,
    population,
    MAX(total_cases) AS Highest_InfectionCases,
    MAX((total_cases) / population) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject.covid_deaths
GROUP BY 1 , 2
ORDER BY PercentPopulationInfected DESC;


-- Showing the countriues with the Highest Death Count per Population 
-- continent NOT NULL
SELECT 
    location,
    MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
FROM
    PortfolioProject.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;


-- By Continent 
SELECT 
    continent,
    MAX(CAST(total_deaths AS SIGNED)) AS Total_Death_Count
FROM
    PortfolioProject.covid_deaths
WHERE
    continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;


-- GLOBAL NUMBERS
SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS SIGNED)) AS total_deaths,
    SUM(CAST(new_deaths AS SIGNED)) / SUM(new_cases) * 100  AS DeathPercentage
FROM
    PortfolioProject.covid_deaths
WHERE
    continent IS NOT NULL
-- GROUP BY date
ORDER BY DeathPercentage;


-- Total Population vs Total Vaccinations
-- Showing Population that has recieved at least one Covid Vaccine in Percentage
SELECT
	date,
    Continent,
    location,
    population,
    new_vaccinations,
    RollingPeopleVaccinated,
    (RollingPeopleVaccinated / population) * 100 AS VaccinationPercentage
FROM (
    SELECT
        D.continent,
        D.location,
        D.date,
        D.population,
        V.new_vaccinations,
        SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject.covid_deaths D
    JOIN
        PortfolioProject.covid_vaccinations V ON D.location = V.location AND D.date = V.date

) AS Subquery
ORDER BY
    location, date;
    
-- or 

SELECT
    D.date,
    D.continent,
    D.location,
    D.population,
    V.new_vaccinations,
    SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) AS RollingPeopleVaccinated,
	(SUM(V.new_vaccinations) OVER (PARTITION BY D.location ORDER BY D.date) / D.population) * 100 AS VaccinationPercentage
FROM
    PortfolioProject.covid_deaths D
JOIN
    PortfolioProject.covid_vaccinations V ON D.location = V.location AND D.date = V.date
-- WHERE D.continent is NOT NULL 
ORDER BY
    D.location, D.date;


-- Using CTE(Common Table Expression) to perform Calculation on Partition By in previous query 
-- (Population vs Vaccination)
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        D.continent,
        D.location,
        D.date,
        D.population,
        V.new_vaccinations,
        SUM(CAST(V.new_vaccinations AS SIGNED)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject.covid_deaths D
    JOIN
        PortfolioProject.covid_vaccinations V
    ON
        D.location = V.location
        AND D.date = V.date
    WHERE
        D.continent IS NOT NULL 
)
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM
    PopvsVac;






--  Comparing the total population with the total number of people who have received at least one COVID vaccine dose
SELECT
    SUM(D.population) AS TotalPopulation,
    SUM(V.new_vaccinations) AS TotalVaccinations,
    (SUM(V.new_vaccinations) / SUM(D.population)) * 100 AS PercentageVaccinated
FROM
    PortfolioProject.covid_deaths D
JOIN
    PortfolioProject.covid_vaccinations V ON D.location = V.location AND D.date = V.date;

-- vaccination coverage for each continent
SELECT
    continent,
    SUM(people_vaccinated_per_hundred) AS total_people_vaccinated,
    SUM(people_fully_vaccinated_per_hundred) AS total_people_fully_vaccinated
FROM covid_vaccinations
GROUP BY continent;

-- overall mortality rate (total deaths per total cases)
SELECT
    SUM(total_deaths) AS total_deaths,
    SUM(total_cases) AS total_cases,
    (SUM(total_deaths) / SUM(total_cases)) * 100 AS mortality_rate
FROM covid_deaths;

-- the highest new deaths per million people
SELECT
    location,
    MAX(new_deaths_per_million) AS max_new_deaths_per_million
FROM covid_deaths
GROUP BY location
ORDER BY max_new_deaths_per_million DESC
LIMIT 10;

-- correlation between vaccination coverage and mortality rate
SELECT
    v.location,
    v.people_fully_vaccinated_per_hundred,
    d.mortality_rate
FROM covid_vaccinations v
JOIN (
    SELECT
        location,
        (SUM(total_deaths) / SUM(total_cases)) * 100 AS mortality_rate
    FROM covid_deaths
    GROUP BY location
) d ON v.location = d.location
ORDER BY v.people_fully_vaccinated_per_hundred DESC;

-- the top 5 locations with the highest positive rate
SELECT
    location,
    MAX(positive_rate) AS max_positive_rate
FROM covid_vaccinations
GROUP BY location
ORDER BY max_positive_rate DESC
LIMIT 5;

