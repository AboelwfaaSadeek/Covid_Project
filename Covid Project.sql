/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


Select  * 
From CovidDeaths
where continent is not null
order by 3,4


--Select * 
--From [dbo].[CovidVacinations]
--order by 3,4



--Select date that we are gonna use it.

Select Location, date, new_cases, total_cases, total_deaths, population
From CovidDeaths
where continent is not null
order by location,date


-- Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as 'Death Percentage'
From CovidDeaths
Where location = 'Egypt' 
order by 1,2


-- Looking at Total Cases Vs Population 
-- Shows what percentage of population infected with Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as 'Total Cases Percentage'
From CovidDeaths
Where location = 'Egypt'
order by 1,2


-- Looking at countriest with Highest infection rate compared to population

Select  Location, population, max(total_cases) as 'Higest Infected count',
	max((total_cases/population)*100) as 'Total Cases Percentage'
From CovidDeaths
where continent is not null
group by location,population
order by 'Total Cases Percentage' desc



-- Showing countires with Highest death count per population

Select  Location, max(cast(total_deaths as int)) as 'Total Death count'
From CovidDeaths
where continent is not null
group by location,population
order by 'Total Death count' desc




-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select  continent, max(cast(total_deaths as int)) as 'Total Death count'
From CovidDeaths
where continent is not null
group by continent
order by 'Total Death count' desc


-- Global Numbers

Select  sum(new_cases) as 'Total new cases',sum(cast(new_deaths as int)) as 'Total new deathes',
sum(cast(new_deaths as int))/sum(new_cases) *100 as 'Death Percentage'
From CovidDeaths
Where continent is not null 
--group by date
order by 1,2



--	Looking at Total population Vs Total Vacinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
	sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) as 'Rolling People Vacinated'
From CovidVaccinations vac 
join CovidDeaths dea 
	on(vac.location = dea.location and vac.date = dea.date)
where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopVsVac ( Continent, Location, Date, Population, New_Vacciniation,RollingPeopleVacinated)

as
(
Select dea.continent, dea.location, cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
	sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) as 'Rolling People Vacinated'
From CovidVaccinations vac 
join CovidDeaths dea 
	on(vac.location = dea.location and vac.date = dea.date)
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVacinated/Population)*100
From PopVsVac
order by 2,3




-- Using Temp Table to perform Calculation on Partition By in previous query

Drop table if exists #PercnetPopulationVaccinated
Create Table #PercnetPopulationVaccinated
(
	Continent nvarchar(255),
	Location  nvarchar(255),
	Date	 datetime,
	population numeric,
	New_Vaccinations numeric,
	RollingPeopleVacinated numeric
)
Insert Into #PercnetPopulationVaccinated
Select dea.continent, dea.location, cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
	sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) as 'Rolling People Vacinated'
From CovidVaccinations vac 
join CovidDeaths dea 
	on(vac.location = dea.location and vac.date = dea.date)
--where dea.continent is not null

Select *, (RollingPeopleVacinated/Population)*100
From #PercnetPopulationVaccinated
order by 2,3



-- Creating View to store data for later visualizations

Alter View PercnetPopulationVaccinated as
Select dea.continent, dea.location, cast(dea.date as date) as date, dea.population, vac.new_vaccinations,
	sum(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.date) as 'Rolling People Vacinated'
From CovidVaccinations vac 
join CovidDeaths dea 
	on(vac.location = dea.location and vac.date = dea.date)
where dea.continent is not null


