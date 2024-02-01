SELECT *
FROM PortfolioProject..CovidDeaths
where continent is null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Look at total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location Like '%states%'
ORDER BY 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of population got covid
SELECT Location, date, population,  total_cases, (total_cases/population)*100 as PercentOfPopulation
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%phili%'
ORDER BY 1,2

-- LOOKING AT COUNTRYS WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT Location, population,  MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PopulationInfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%phili%'
Group By location, population
ORDER BY population desc

-- Showing Countries with HIghest Death Count per Population
SELECT Location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%phili%'
WHERE continent is not null
Group By location
ORDER BY TotalDeathCount desc

-- LETS BREAK THIS DOWN BY CONTINENT
SELECT location, MAX(cast(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location Like '%phili%'
WHERE continent is null
Group By location
ORDER BY TotalDeathCount desc

SELECT location, SUM(CAST(total_deaths as INT)) as tOTS
FROM PortfolioProject..CovidDeaths
WHERE continent is null
AND location = 'World'
group by location

-- Showing contonents with Highest death counts
SELECT continent, max(CAST(total_deaths as INT)) as ConHighestDeathCounts
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
group by continent
order by ConHighestDeathCounts desc


-- Global Numbers
SELECT Date,  SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, (SUM(cast(new_deaths as INT))/SUM(new_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
Group by date
Order by 1,2

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, (SUM(cast(new_deaths as INT))/SUM(new_cases)*100) as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null 
--Group by date
Order by 1,2


-- Looking at the Total Population VS Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (Continent,Location,Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--Temp TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store for later data visualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated