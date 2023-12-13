
select *
from [portfolio ]..CovidVaccinations
where continent is not null
order by 3,4

select location, date, total_cases, new_cases,total_deaths, population
from [portfolio ]..CovidDeaths
----order by 1,2 

--looking at total casses vs total death
--where location like '%states%' = digunakan untuk mencari lokasi secara menjurus


--where location like '%states%'
--And continent is not null
-- jika ada syntact where tambah and 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentance
from [portfolio ]..CovidDeaths
where location like '%states%'
And continent is not null
----order by 1,2 

--show like li hood of dying if you contract tehe covid in your country
--looking at Total cases vs population

select location, date, population,total_cases,  (total_cases/population)*100 as PopulationPercentance
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

-- looking at coubtry with highest infection rate  compared to population 

select location, population,max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as PercentPopulationInfected
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location,population
order by PercentPopulationInfected desc

--showing country with highwst death count per population 

select location,max(cast(total_deaths as int )) as TotalDeathCount 
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--lets break thing by continent 

select continent,max(cast(total_deaths as int )) as TotalDeathCount 
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- showing continent with hight death 

select continent,max(cast(total_deaths as int )) as TotalDeathCount 
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- global number
select sum (total_cases) as total_cases, sum(cast(new_deaths as int)) as total_death, sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentange
from [portfolio ]..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date 
order by 1,2 

-- looking at total population vs vactination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) OVER ( PARTITION by dea.location, dea.date)
as RollingPeopleVactinated
from [portfolio ]..CovidDeaths dea
join [portfolio ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVactinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) OVER ( PARTITION by dea.location, dea.date)
as RollingPeopleVactinated
--,(RollingPeopleVactinated/population)*100
from [portfolio ]..CovidDeaths dea
join [portfolio ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVactinated/population)*100
from PopvsVac

-- temp table 
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar (255),
Location varchar(255),
date datetime,
population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) OVER ( PARTITION by dea.location, dea.date)
as RollingPeopleVactinated
--,(RollingPeopleVactinated/population)*100
from [portfolio ]..CovidDeaths dea
join [portfolio ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--create view too store data for later visualizations 

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert (int,vac.new_vaccinations)) OVER ( PARTITION by dea.location, dea.date)
as RollingPeopleVactinated
--,(RollingPeopleVactinated/population)*100
from [portfolio ]..CovidDeaths dea
join [portfolio ]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated