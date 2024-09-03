select*
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4

--select*
--from [Portfolio Project]..vaccinations

-- select data

select location, date ,total_cases,new_cases,total_deaths,population
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- show likelihood of dying if u contract covid in your country
select location, date ,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%'
order by 1,2


-- looking at total case vs population
-- show what percentage of population get covid

select location, date ,population,total_cases , (total_cases/population)*100 as ss
from [Portfolio Project]..CovidDeaths
order by 1,2


-- looking at countries with highest infection rate compared to population

select location, population,max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
PercentagePopulationInfected
from [Portfolio Project]..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc


-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


-- let's break things down by continent


-- showing continent with the hightest death 

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- global numbers 

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where continent is not null
--group by date
order by 1,2




--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int ,vac.new_vaccinations )) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use cte

with PopvsVac(continent, location, date,population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int ,vac.new_vaccinations )) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *,(RollingPeopleVaccinated/population)*100
from PopvsVac




-- temp table

drop table if exists #PercenPopulationVaccinated
create table #PercenPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercenPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int ,vac.new_vaccinations )) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercenPopulationVaccinated



--creating view to store data for later visulaizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int ,vac.new_vaccinations )) over(partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated