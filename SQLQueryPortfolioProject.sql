
select * 
from PortfolioProject..CovidDeaths

order by 2, 3

select * 
from PortfolioProject..CovidVaccinations
order by 2, 3

--select data that we are going to use 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

order by 1

--setting Varchar data to float for operations
select cast(total_deaths as float) as new_total_deaths
from PortfolioProject..CovidDeaths

-- Casting total cases to float as new total cases.
Select cast(total_cases as float) as new_total_cases
from PortfolioProject..CovidDeaths

--Looking at Total cases vs Total Deaths
--shows the liklyhood of dying if you contract covid in these counties

select location, date, total_cases,  total_deaths,(cast(total_deaths as float))/(cast(total_cases as float))*100 as Death_percentage
from PortfolioProject..CovidDeaths
where total_cases <> 0 

order by 1

--Looking at Total cases vs Population


select location, date,Population, total_cases,  total_deaths,(cast(total_deaths as float))/(cast(total_cases as float))*100 as Death_percentage
from PortfolioProject..CovidDeaths
where total_cases <> 0 

order by 1

-- Countries with highest infection rate compared to population



select location, Population,  max(total_cases) as HighestInfectioCount, max((cast(total_cases as float)/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location, population

order by PercentagePopulationInfected desc

--Showing the countries with the highest deathcount per population

select location,   max(cast(total_cases as float)) as HighestDeathCount, max((cast(total_cases as float)/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location
order by HighestDeathCount desc

-- Showing the continents with the highest deathcount per population

select continent,   max(cast(total_cases as float)) as HighestDeathCount, max((cast(total_cases as float)/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by continent
order by HighestDeathCount desc

-- global numbers

select sum(cast(new_cases as bigint)) as total_cases, sum(cast(new_deaths as bigint)) as total_deaths

--,sum(cast(new_deaths as bigint))/sum(cast(new_cases as bigint))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where new_cases <> 0


--joining two tables on 2 Attributes

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at Totl populations vs Vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date

order by 2,3

--Rolling new vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
order by 2,3

-- use CTE

with popvsvac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
)
select *
from popvsvac

--Temp Table
drop table if exists #PercentPopulationVaccinated 

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations bigint,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


-- Creating view to store data for later visualizations

create view DeathCounts as 
select continent,   max(cast(total_cases as float)) as HighestDeathCount, max((cast(total_cases as float)/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by continent
--order by HighestDeathCount desc


 
create view PercentPopulationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date



