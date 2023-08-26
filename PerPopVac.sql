-- This is a VIEW

USE PortfolioProject;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    (SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) / dea.population) * 100 AS VaccinationPercentage
FROM 
    covid_deaths dea
JOIN 
    covid_vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
    ORDER BY 2,3;

--  Retrieving all rows and columns from the View
SELECT * FROM PercentPopulationVaccinated;

SELECT * FROM PercentPopulationVaccinated WHERE continent = 'Asia';

SELECT continent, AVG(VaccinationPercentage) AS AvgVaccinationPercentage
FROM PercentPopulationVaccinated
GROUP BY continent;

SELECT location, date, VaccinationPercentage
FROM PercentPopulationVaccinated
WHERE location = 'India'
ORDER BY date;


