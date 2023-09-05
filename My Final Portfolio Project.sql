SELECT * 
from PortfolioProject.dbo.['covid deaths f$']
WHERE continent is not null
order by 3,4

SELECT *
FROM PortfolioProject.dbo.CovidVaccination2$

SELECT DATE,location, total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.['covid deaths f$']

--Looking at Total Cases VS Total Deaths

SELECT location,date, total_cases,total_deaths,ROUND((total_deaths/total_cases),4)*100 as DeathPercentage
from PortfolioProject.dbo.['covid deaths f$']
where total_cases<>0 and continent is not null
order by 1,2

--Looking at Total Cases VS Population
--Shows what Percentage of population got covid

SELECT location,date,population,total_cases,ROUND((total_cases/population),4)*100 as CovidAffected
from PortfolioProject.dbo.['covid deaths f$']
where continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate
SELECT location,population,MAX(total_cases) AS HighestInfectionCount ,ROUND((MAX(total_cases/population)),4)*100 as CovidAffected
from PortfolioProject.dbo.['covid deaths f$']
where continent is not null
Group by location,population
order by CovidAffected desc

--Showing Countries with Highest Death Rate per Population

SELECT location,MAX(total_deaths) AS HighestDeathCount 
FROM PortfolioProject.dbo.['covid deaths f$']
where continent is not null
Group by location
order by HighestDeathCount desc
 

 --LETS BREAK THINGS DOWN BY CONTINENT 

SELECT continent,MAX(total_deaths) AS HighestDeathCount 
FROM PortfolioProject.dbo.['covid deaths f$']
where continent is not null
Group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TOTAL_CASES , SUM(new_deaths) AS TOTAL_DEATHS ,SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.['covid deaths f$']
where new_cases<>0 and continent is not null
GROUP BY date
order by 1,2

--JOINING BOTH TABLES
SELECT * 
FROM PortfolioProject.dbo.['covid deaths f$'] DEA
JOIN PortfolioProject.dbo.CovidVaccination2$ VAC
ON DEA.location=VAC.location
AND DEA.date=VAC.date

--LOOKING AT TOTAL POPULATION VS DEATHS
SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations
FROM PortfolioProject.dbo.['covid deaths f$'] DEA
JOIN PortfolioProject.dbo.CovidVaccination2$ VAC
ON DEA.location=VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

SELECT DEA.continent, DEA.location,DEA.date,DEA.population, VAC.new_vaccinations, 
SUM(VAC.new_vaccinations) OVER (Partition by DEA.location ORDER BY DEA.location, DEA.date) as RollingPeopleVaccinated

FROM PortfolioProject.dbo.['covid deaths f$'] DEA
JOIN PortfolioProject.dbo.CovidVaccination2$ VAC
ON DEA.location=VAC.location
AND DEA.date=VAC.date
WHERE DEA.continent is not null
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (Partition by DEA.Location Order by DEA.location, DEA.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.DBO.['covid deaths f$'] DEA
Join PortfolioProject.DBO.CovidVaccination2$ VAC
	On DEA.location = VAC.location
	and DEA.date = VAC.date
where DEA.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeopleVaccinated
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['covid deaths f$'] dea
Join PortfolioProject.dbo.CovidVaccination2$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['covid deaths f$'] dea
Join PortfolioProject.dbo.CovidVaccination2$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated