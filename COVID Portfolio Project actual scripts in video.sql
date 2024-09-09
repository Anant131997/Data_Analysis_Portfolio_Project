SELECT * FROM CovidDeaths 
where continent is not null
ORDER BY 3,5;

-- SELECT THE DATA FROM DATABASE WHICH YOU WANT TO USE

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM CovidDeaths
where continent is not null
ORDER BY 1,2;


-- LOOKING AT TOTAL CASES VS TOTAL DEATHS
-- Shows chances of dying if you contacted with covid in your country.
SELECT location,date,total_cases,total_deaths, 
CONVERT(DECIMAL(10,2),(total_deaths/total_cases)*100) AS DEATH_PERCENTAGE,
ROUND((total_deaths/total_cases)*100, 0) AS APPROX_PERCENTANGE
FROM CovidDeaths 
WHERE location = 'INDIA'
and continent is not null
ORDER BY 1,2 


-- LOOKING AT TOTAL CASES VS TOTAL POPULATION
-- Shows what percentage of people got Covid.
SELECT location,date,total_cases,total_deaths, population,
CONVERT(DECIMAL(10,3),(total_cases/population)*100) AS PercentPopulationInfected 
FROM CovidDeaths
where continent is not null
--WHERE location = 'INDIA'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate comapred to Population

SELECT location,Max(total_cases) AS HighestInfectionCount, population,
Max((total_cases/population))*100 AS PercentPopulationInfected 
FROM CovidDeaths
where continent is not null
--WHERE location = 'INDIA'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc


-- Showing the countries with highest death count per Population 
SELECT location,Max(cast(total_deaths as int)) AS HighestDeathCount 
--population, Max((total_deaths/population))*100 AS DeathPercent 
FROM CovidDeaths
where continent is not null
--WHERE location = 'INDIA'
GROUP BY location,population
ORDER BY HighestDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with highest death count
SELECT location,Max(cast(total_deaths as int)) AS HighestDeathCount 
FROM CovidDeaths
where continent is null
GROUP BY location
ORDER BY HighestDeathCount desc


-- GLOBAL NUMBERS
SELECT SUM(NEW_CASES) TOTAL_CASES, SUM(CAST(NEW_DEATHS AS int)) TOTAL_DEATHS,
CONVERT(decimal(10,2),(SUM(cast(new_deaths as int))/sum(new_cases))*100) as DeathPercentage
FROM CovidDeaths 
WHERE continent is not null
ORDER BY 1,2 

-- Looking at Total Population vs Vaccination

SELECT  CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL
ORDER BY 2,3


-- use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
SELECT  CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL
)
select *, CONVERT(DECIMAL(10,2),(RollingPeopleVaccinated/population)*100) AS Percent_People_Vaccinated
from PopVsVac


-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(50),
Date datetime,
Population int,
New_Vaccinations int,
RollingPeopleVaccinated int
)
INSERT INTO #PercentPopulationVaccinated
SELECT  CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL


select *, CONVERT(DECIMAL(10,2),(RollingPeopleVaccinated/population)*100) AS Percent_People_Vaccinated
from #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

CREATE VIEW PercentPopulationVaccinated as 
SELECT  CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS int)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV
	ON CD.location = CV.location
	AND CD.date = CV.date
	WHERE CD.continent IS NOT NULL
	--order by 2,3

select * 
from PercentPopulationVaccinated
