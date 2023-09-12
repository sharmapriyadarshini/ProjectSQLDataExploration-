USE PortfolioProject;

-- Using Temp Table to perform Calculation on Partition By in previous query
-- Dropping Table
Drop TABLE IF EXISTS PercentPopulationVaccinated; 

-- Create the table
CREATE TABLE PercentPopulationVaccinated (
    Continent VARCHAR(255) CHARACTER SET utf8mb4,
    Location VARCHAR(255) CHARACTER SET utf8mb4,
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Inserting data in to the temporary table
INSERT INTO PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%y') AS date,
    dea.population,
    CASE
        WHEN vac.New_vaccinations = '' THEN 0
        ELSE vac.New_vaccinations
    END AS New_vaccinations,
    SUM(vac.New_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, STR_TO_DATE(dea.date, '%m/%d/%y')) AS RollingPeopleVaccinated
FROM
    PortfolioProject.covid_deaths dea
JOIN
    PortfolioProject.covid_vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL
ORDER BY
    dea.location,
    STR_TO_DATE(dea.date, '%m/%d/%y');

-- Retrieve data from the temporary table
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM
    PercentPopulationVaccinated;


-- the average vaccination rate (percentage of population vaccinated) for each continent
SELECT
    Continent,
    AVG((RollingPeopleVaccinated / Population) * 100) AS AvgVaccinationRate
FROM PercentPopulationVaccinated
GROUP BY Continent;

-- locations where the highest rolling count of people vaccinated
SELECT
    Location,
    MAX(RollingPeopleVaccinated) AS MaxRollingVaccinated
FROM PercentPopulationVaccinated
GROUP BY Location
ORDER BY MaxRollingVaccinated DESC
LIMIT 10;



-- Exploring data for my Home Country India

-- the rolling vaccination count progressed over time for India
SELECT
    Location,
    Date,
    RollingPeopleVaccinated
FROM PercentPopulationVaccinated
WHERE Location = 'India'
ORDER BY Date;

-- the vaccination rate and mortality rate changed over time in India
SELECT
    d.Date,
    (v.RollingPeopleVaccinated / d.Population) * 100 AS VaccinationRate,
    (d.total_deaths / d.total_cases) AS MortalityRate
FROM Covid_deaths d
JOIN PercentPopulationVaccinated v ON d.Location = v.Location AND d.Date = v.Date
WHERE d.Location = 'India'
ORDER BY d.Date;

-- Fining the trend of new cases and new vaccinations in India over time
SELECT
    d.Date,
    d.new_cases,
    v.new_vaccinations
FROM Covid_deaths d
JOIN PortfolioProject.covid_vaccinations v ON d.Location = v.Location AND d.Date = v.Date
WHERE d.Location = 'India'
ORDER BY d.Date;

-- the vaccination percentage increased in India over time
SELECT
    Date,
    (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated
WHERE Location = 'India'
ORDER BY Date;

SELECT * FROM covid_vaccinations
WHERE continent = 'North America' and location = 'mexico';


-- tried to Comparing Vaccination and Mortality Rates for India and North America:
/* SELECT
    d_india.Date,
    (v_india.RollingPeopleVaccinated / d_india.Population) * 100 AS VaccinationRate_India,
    (d_india.total_deaths / d_india.total_cases) AS MortalityRate_India,
    (v_na.RollingPeopleVaccinated / d_na.Population) * 100 AS VaccinationRate_NA,
    (d_na.total_deaths / d_na.total_cases) AS MortalityRate_NA
FROM covid_deaths d_india
JOIN PercentPopulationVaccinated v_india ON d_india.Location = v_india.Location AND d_india.Date = v_india.Date
JOIN covid_deaths d_na ON d_na.continent = 'North America' AND d_india.Date = d_na.Date
JOIN PercentPopulationVaccinated v_na ON d_na.Location = v_na.Location AND d_na.Date = v_na.Date
WHERE d_india.Location = 'India'
ORDER BY d_india.Date;

SELECT
    d_india.Date,
    AVG((v_india.RollingPeopleVaccinated / d_india.Population) * 100) AS AvgVaccinationPercentage_India,
    AVG((v_na.RollingPeopleVaccinated / d_na.Population) * 100) AS AvgVaccinationPercentage_NA
FROM PercentPopulationVaccinated v_india
JOIN covid_deaths d_india ON v_india.Location = d_india.Location AND v_india.Date = d_india.Date
JOIN PercentPopulationVaccinated v_na ON d_india.Date = v_na.Date
JOIN covid_deaths d_na ON v_na.Location = d_na.Location AND v_na.Date = d_na.Date
WHERE d_india.Location = 'India' AND d_na.continent = 'North America'
GROUP BY d_india.Date
ORDER BY d_india.Date;
*/


-- comparison Between Asia and North Ameria 

-- How have the vaccination rate and mortality rate changed over time for Asia and North America?
SELECT
    d.`Date`,
    d.continent,
    SUM(d.new_cases) AS TotalNewCases,
    SUM(v.new_vaccinations) AS TotalNewVaccinations
FROM covid_deaths d
JOIN covid_vaccinations v ON d.Location = v.Location AND d.`Date` = v.`Date`
WHERE d.continent IN ('Asia', 'North America')
GROUP BY d.`Date`, d.continent
ORDER BY d.`Date`, d.continent;


-- the trend of new cases and new vaccinations for Asia and North America over time
SELECT
    d.Date,
    d.continent,
    SUM(d.new_cases) AS TotalNewCases,
    SUM(v.new_vaccinations) AS TotalNewVaccinations
FROM covid_deaths d
JOIN covid_vaccinations v ON d.Location = v.Location AND d.Date = v.Date
WHERE d.continent IN ('Asia', 'North America')
GROUP BY d.Date, d.continent
ORDER BY d.Date, d.continent;

-- the vaccination percentage increased over time for Asia and North America?
SELECT
    Date,
    continent,
    AVG((RollingPeopleVaccinated / Population) * 100) AS AvgVaccinationPercentage
FROM PercentPopulationVaccinated
WHERE continent IN ('Asia', 'North America')
GROUP BY Date, continent
ORDER BY Date, continent;
