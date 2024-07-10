Select *
From [portfolio project]. .[covid deaths]
order by 3,4

Select *
From [portfolio project]. .[covid vaccinations]
order by 3,4

--select Data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
from [portfolio project]. .[covid deaths]
order by 1,2

--looking at Total cases vs Total Deaths

Select Location, date, total_cases, new_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]. .[covid deaths]
order by 1,2

-- Looking at total cases vs population 
--shows what percentage of population got covid


Select Location, date,total_cases, population,
(total_cases/population)* 100 as PercentagePopulationInfected
From [portfolio project]. .[covid deaths]
order by 1,2

--Looking at countries with Highest Infection Rate Compared to Population 
Select Location, population, MAX(Total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]. .[covid deaths]
Group by location, population order by PercentPopulationInfected desc

--Showing countries with Highest Death Count 
Select continent, Location, max(cast(total_deaths as int)) as MaxTotalDeath
From [portfolio project]. .[covid deaths]
Where continent is not null 
group by location, continent
order by continent

--Let's break things by continent

Select continent, max(cast(total_deaths as int)) as MaxTotalDeath
From [portfolio project]. .[covid deaths]
Where continent is not null 
group by  continent
order by MaxTotalDeath desc

--Global numbers

Select  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,
sum(cast(new_deaths as int)) / sum(cast( new_cases as int))* 100 as DeathPercentage
From [portfolio project]. .[covid deaths]
Where continent is not null
order by 1,2

--looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast( vac.new_vaccinations as int)) OVER (partition by dea.Location
order by dea.location, dea.Date) as RollingPeopleVaccinated
From [portfolio project]. .[covid deaths] dea
JOIN [portfolio project]. .[covid vaccinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--CTE

With popvsvac (continent, location,Date, population, new_vaccinations, 
RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast( vac.new_vaccinations as int)) OVER (partition by dea.Location
order by dea.location, dea.Date) as RollingPeopleVaccinated
From [portfolio project]. .[covid deaths] dea
JOIN [portfolio project]. .[covid vaccinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
)
Select * , (RollingPeopleVaccinated/population)*100
From popvsvac



--TEMP TABLE


DROP TABLE if exists #percentPopulationvaccinated
CREATE TABLE #percentPopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #percentPopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,Sum(cast( vac.new_vaccinations as int))
OVER (partition by dea.Location order by dea.location, dea.Date) 
as RollingPeopleVaccinated
From [portfolio project]. .[covid deaths] dea
JOIN [portfolio project]. .[covid vaccinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Select * , (RollingPeopleVaccinated/population)*100
From #percentPopulationvaccinated


--create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) OVER (partition by dea.Location
order by dea.location, dea.Date) as RollingPeopleVaccinated
From [portfolio project]. .[covid deaths] dea
JOIN [portfolio project]. .[covid vaccinations] vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 



