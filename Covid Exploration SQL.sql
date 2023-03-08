


-- Looking at Total Cases vs. Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where location = 'United States'
order by 1,2 desc




-- Looking at Total Cases vs. Population
-- shows what percentage of population contracted covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths$
where location = 'United States'
order by 1,2




-- Looking at Countries with Highest Percent of Population Infected

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths$
group by location, population
order by PercentPopulationInfected desc




-- Looking at Countries with Highest Death Count

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc




-- Showing Continents with Highest Death Count

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc




-- Global Case and Death Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from dbo.CovidDeaths$
where continent is not null
order by 1,2




-- Join Covid Death and Covid Vaccination Tables

select *
from dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
on dea.location = vac.location
and dea.date = vac.date
order by dea.location




-- Looking at Total Population vs. Total Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from dbo.CovidDeaths$ as dea
join dbo.CovidVaccinations$ as vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Creat CTE

WITH popvsvacc AS
(
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ as dea
join  dbo.CovidVaccinations$ as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
-- order by 2, 3

)
select *, (RollingPeopleVaccinated/population)*100
from popvsvacc







-- Temp Table


create table PercentPopulationVaccinated
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths$ as dea
join  dbo.CovidVaccinations$ as vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
-- order by 2, 3

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated
