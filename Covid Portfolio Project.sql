SELECT *
FROM CovidDeaths



SELECT *
FROM CovidVaccinations
ORDER BY 3,4

------Select The Data to Use
SELECT Location, Date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

------Total Cases VS Total Deaths
SELECT Location, Date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths
WHERE location LIKE 'Nigeria'
ORDER BY 1,2
--Population that has COVID
SELECT Location, Date, total_cases,population, (total_cases/population)*100 AS Confirmed_Percentage
FROM CovidDeaths
ORDER BY 1,2

----Countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS Highest_Infection_Case,population, MAX(total_cases/population)*100 AS Confirmed_Percentage
FROM CovidDeaths
WHERE Location LIKE 'Nigeria'
GROUP BY location, population
ORDER BY 1,2

--Country with Highest Death Rate
SELECT Location, MAX(total_deaths) AS Highest_death
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Highest_death DESC

----Viewing By Continent
SELECT continent, MAX(total_deaths) AS Highest_death
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_death DESC

----Continent with highest death count
SELECT continent, MAX(total_deaths) AS Highest_Death_Count
FROM CovidDeaths
Where continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC

----Global Numbers
SELECT YEAR(Date) AS Year, SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY YEAR(Date)
ORDER BY 1,2

----Total Population VS Vaccinations
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations, 
	SUM(CONVERT(int,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Vaccinated,
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location=CV.location
	AND CD.date=CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3

----Rolling_Vaccinated/population)*100
WITH PopVsVac (continent,location,date,population,new_vaccinations,Rolling_Vaccinated)
AS
(SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations, 
	SUM(CONVERT(float,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Vaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location=CV.location
	AND CD.date=CV.date
WHERE CD.continent IS NOT NULL

)

SELECT *, (Rolling_Vaccinated/population)*100 AS Percentage_Vaccinated
FROM PopVsVac
ORDER BY 2,3

--Temp Table
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations, 
	SUM(CONVERT(int,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Vaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location=CV.location
	AND CD.date=CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (Rolling_Vaccinated/population)*100 AS Percentage_Vaccinated
FROM #PercentagePopulationVaccinated


--Creating View to Store Data for Visualization
Create VIEW PercentagePopulationVaccinated AS
SELECT CD.continent, CD.location, CD.date,CD.population,CV.new_vaccinations, 
	SUM(CONVERT(int,CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS Rolling_Vaccinated
FROM CovidDeaths AS CD
JOIN CovidVaccinations AS CV
	ON CD.location=CV.location
	AND CD.date=CV.date
WHERE CD.continent IS NOT NULL


SELECT *
FROM PercentagePopulationVaccinated