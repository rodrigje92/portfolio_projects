Select *
From PortfolioProject..CovidDeaths
where continent is not null
 Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4 

-- Selecting data we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at total cases vs. total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Looking at total cases vs population
Select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order by 1,2

-- Which countries have the highest infection rate compared to population
Select location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population))*100 as infection_rate
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by location, population
Order by infection_rate desc

--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
Group by location
Order by total_death_count desc

--showing continents breakdown of highest death count per population
Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
--Where location like '%states%'
--where continent is null
where location not like ('%income%') AND continent is null
Group by location
Order by total_death_count desc 

--global cases by day
select date, SUM(new_cases) as cases_per_day, SUM(cast(new_deaths as int)) as deaths_per_day, (SUM(cast(new_deaths as int))/sum(new_cases))*100 as new_death_to_case_ratio
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2 


-- Look at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_vaccinations
, total_vaccinations/dea.population * 100 as vaccinated_population
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where (dea.continent is not null) --AND (dea.location like '%states%')
order by 2,3


--Temp Table
drop table if exists #percent_of_pop_vaccinated
Create Table #percent_of_pop_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
totalvaccinations numeric
)


insert into #percent_of_pop_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as totalvaccinations
--, total_vaccinations/dea.population * 100 as vaccinated_population
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where (dea.continent is not null) --AND (dea.location like '%states%')
--order by 2,3

select *, (totalvaccinations/population)*100
from #percent_of_pop_vaccinated


--creating view to store data for later visualizations
--drop view if exists percentofpopvaccinated
create view percentofpopvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as total_vaccinations
, total_vaccinations/population * 100 as vaccinated_population_percent
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where (dea.continent is not null) --AND (dea.location like '%states%')
order by 2,3

