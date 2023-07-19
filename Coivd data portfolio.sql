--SELECT *
--FROM CovidDeaths
--WHERE continent is not null
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..covidvaccination
--ORDER BY 3,4

--Data we are going to use-->

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 1) calculating death percentage as per total cases vs total deaths
SELECT location,date,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathpercent
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 2) calculation for countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) as highestInfectionCount,MAX((total_cases/population))*100 
as percentpopulationinfected
FROM CovidDeaths
WHERE continent is not null
GROUP BY location,population 
ORDER BY percentpopulationinfected  desc

--NOTE--> this above data can be used to analyse the control rate and measures took by specific country.

-- 3) Shows the countries with highest death count compared to population
SELECT location,MAX(cast(total_deaths as bigint)) as totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location 
ORDER BY totalDeathCount  desc

-- 4) Breaking down the data on basis of continent-->
SELECT location as Continent_world ,MAX(cast(total_deaths as bigint)) as totalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location 
ORDER BY totalDeathCount  desc

-- 5) Showing continent with the highest deathcount-->
SELECT continent,MAX(cast(total_deaths as bigint)) as totalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount  desc

-- 6) Breaking into global numbers
SELECT date,SUM(new_Cases) as new_cases,SUM(CAST(new_deaths as bigint)) as new_deaths,SUM(CAST(new_deaths as bigint))/SUM(new_cases) *100 as deathpercent
FROM CovidDeaths
WHERE continent is not null
GROUP BY  date
ORDER BY 1,2

-- 7) For overall global data-->
SELECT SUM(new_Cases) as new_cases,SUM(CAST(new_deaths as bigint)) as new_deaths,SUM(CAST(new_deaths as bigint))/SUM(new_cases) *100 as deathpercent
FROM CovidDeaths
WHERE continent is not null
--GROUP BY  date
ORDER BY 1,2

--IMPORTANT--> Now we join the tables of deaths and vaccination-->

SELECT *
FROM CovidDeaths as de
JOIN CovidVaccination as va
  ON  de.location = va.location 
  AND de.date = va.date

-- 8) We are looking for total vacciantion V/S total population

SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CAST(va.new_vaccinations as int))OVER (PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM CovidDeaths as de
JOIN CovidVaccination as va
  ON  de.location = va.location 
  AND de.date = va.date
  WHERE de.continent is not null
  ORDER BY 2,3

-- 9) For calculating RollingPeopleVaccinated percentage--> We need to use CTE/temp tables

-- i) CTE-->
WITH popVSvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CAST(va.new_vaccinations as int))OVER (PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM CovidDeaths as de
JOIN CovidVaccination as va
  ON  de.location = va.location 
  AND de.date = va.date
  WHERE de.continent is not null
 -- ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/population)*100 
FROM popVSvac

--NOTE--'(RollingPeopleVaccinated/population)*100' this statement gives table which shows the percentage of population vaccinated. 

--ii) Temp Table-->
DROP TABLE IF exists #ppv
CREATE TABLE #ppv
(continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 INSERT INTO #ppv
 SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CAST(va.new_vaccinations as int))OVER (PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM CovidDeaths as de
JOIN CovidVaccination as va
  ON  de.location = va.location 
  AND de.date = va.date
 -- WHERE de.continent is not null
 -- ORDER BY 2,3

 SELECT * ,(RollingPeopleVaccinated/population)*100 
FROM #ppv

-- 10) Creating a view-->

CREATE VIEW  popeva as
SELECT de.continent,de.location,de.date,de.population,va.new_vaccinations
,SUM(CAST(va.new_vaccinations as int))OVER (PARTITION BY de.location ORDER BY de.location,de.date) as RollingPeopleVaccinated
FROM CovidDeaths as de
JOIN CovidVaccination as va
  ON  de.location = va.location 
  AND de.date = va.date
  WHERE de.continent is not null
 -- ORDER BY 2,3

 SELECT * 
 FROM popeva
