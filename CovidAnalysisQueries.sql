--Select the data to be used from Tables 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent is not NULL
ORDER BY 1,2

-- Now lets get the percentage of deaths over total cases
-- This represents the likelihood of dying if infected in Cameroon
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 AS Percentage_deaths
FROM CovidDeaths$
WHERE location = 'Cameroon' AND continent is not NULL
ORDER BY 1,2 desc

--Next lets get the percentage of cases over population
--This represents the dayly risks of getting infected in Cameroon

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_infections
FROM CovidDeaths$
WHERE location = 'Cameroon' AND continent is not NULL
ORDER BY 1,2


-- Looking now at the highest infection rate per country

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS MaxInfections
FROM CovidDeaths$
--WHERE location = 'Cameroon'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 4 desc


-- Now lets pull out the country with highest death counts 

SELECT location, population, MAX(cast(total_deaths as int)) AS HighestdeathCount, MAX((total_deaths/population))*100 AS Maxdeaths
FROM CovidDeaths$
--WHERE location = 'Cameroon'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 3 desc

-- Splitting out by Continent (Has an error cause dataset contains several continent cell 
-- which are NULL and several location cells which shows continents instead of countries)

SELECT location, population, MAX(cast(total_deaths as int)) AS HighestdeathCount, MAX((total_deaths/population))*100 AS Maxdeaths
FROM CovidDeaths$
--WHERE location = 'Cameroon'
WHERE continent is NULL
GROUP BY location, population
ORDER BY 3 desc



-- Now lets try getting the dayly death and deathrate in the world

SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not NULL
Group BY date 
ORDER BY 1 

--  Global Numbers  (World Deatrate)


SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not NULL
--Group BY date 
ORDER BY 1 


-- Lets move now to the next step which is getting out dayly vaccinations per  

SELECT continent, location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition BY location ORDER BY location, date) AS RollingPeopleVaccinated
FROM CovidVaccinations$
WHERE continent is not NULL
ORDER BY 2,3

-- Using CTE to perform Calculation(Percentage population Vaccinated) on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select continent, location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition BY location ORDER BY location, date) AS RollingPeopleVaccinated
From CovidVaccinations$ 
where continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopVaccinated
From PopvsVac



-- Using Temp Table to perform Calculation (Percentage population Vaccinated) on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select continent, location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition BY location ORDER BY location, date) AS RollingPeopleVaccinated
From CovidVaccinations$ 
where continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT continent, location, date, population, new_vaccinations,
SUM(cast(new_vaccinations as bigint)) OVER (Partition BY location ORDER BY location, date) AS RollingPeopleVaccinated
FROM CovidVaccinations$
WHERE continent is not NULL


--  View 1

CREATE VIEW WorldsDeathRate AS
SELECT SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not NULL
--Group BY date 


-- View 2

CREATE VIEW DaylyDeathRate AS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths$
WHERE continent is not NULL
Group BY date 


--View 3

CREATE VIEW HighestDeathCount AS
SELECT location, population, MAX(cast(total_deaths as int)) AS HighestdeathCount, MAX((total_deaths/population))*100 AS Maxdeaths
FROM CovidDeaths$
--WHERE location = 'Cameroon'
WHERE continent is not NULL
GROUP BY location, population
--ORDER BY 3 desc

-- View 4

CREATE VIEW HighestInfectionCount AS
SELECT location, population, MAX(cast(total_deaths as int)) AS HighestdeathCount, MAX((total_deaths/population))*100 AS Maxdeaths
FROM CovidDeaths$
--WHERE location = 'Cameroon'
WHERE continent is not NULL
GROUP BY location, population
--ORDER BY 3 desc


-- View 5

CREATE VIEW DaylyInfectionPercentage AS 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_infections
FROM CovidDeaths$
WHERE location = 'Cameroon' AND continent is not NULL
--ORDER BY 1,2

-- View 6

CREATE VIEW DaylyDeathPercentage AS
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 AS Percentage_deaths
FROM CovidDeaths$
WHERE location = 'Cameroon' AND continent is not NULL
--ORDER BY 1,2 desc