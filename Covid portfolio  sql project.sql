--Checking if data we loaded is okay

select * from Projekat..CovidDeaths
where continent is not null
order by 3, 4

select * from Projekat..CovidVaccinations
order by 3, 4

--Selecting data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population from Projekat..CovidDeaths
order by 1, 2

--Looking at total cases vs total deaths

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as death_percentage from Projekat..CovidDeaths
where location like 'Bos%' 
order by 1, 2


--Total cases vs Population(percentage of people who got covid)

select location, date, total_cases, population, (total_cases/population)*100 as infection_percentage from Projekat..CovidDeaths
where location like 'Bos%'
order by 1, 2

-- Countires with highest infection rate compared to population

select top 10 location, population, max(total_cases) as till_today_cases, max((total_cases/population)*100) as pct_of_population_had_covid from Projekat..CovidDeaths
group by location, population
order by 4 desc

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_deaths from Projekat..CovidDeaths
where continent is not null
group by location
order by 2 desc


-- Death vs population rate

select location, population, (max(cast(total_deaths as int))/population)*100 as death_vs_population from Projekat..CovidDeaths
where continent is not null
group by location, population
order by 3 desc



-- Breakdown by continent

-- Continents with highest death count per population

select continent, max(cast(total_deaths as int)) from Projekat..CovidDeaths
where continent is not null
group by continent
order by 2

-- Global numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_pct from Projekat..CovidDeaths
where continent is not null
group by date
order by 1, 2


-- Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rolling_people_vaccinated
from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rolling_people_vaccinated
from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- With cte

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rolling_people_vaccinated
from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (rolling_people_vaccinated/population)*100 from popvsvac


-- With temp table

drop table if exists #pctpopvac

create table #pctpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, new_vaccinations numeric,
rolling_people_vaccinated numeric)


insert into #pctpopvac

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rolling_people_vaccinated
from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (rolling_people_vaccinated/population)*100 from #pctpopvac



-- Creating view to store data fot later viz

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ROWS UNBOUNDED PRECEDING) as rolling_people_vaccinated
from Projekat..CovidDeaths dea
join Projekat..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3


select * from PercentPopulationVaccinated