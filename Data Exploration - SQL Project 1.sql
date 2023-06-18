--Covid 19 Data Exploration

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProjects.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects.dbo.CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProjects.dbo.CovidDeaths
Where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate ompared to Population

Select Location, Population, Max(Total_cases) as HighestinfectionCount,  Max(total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Group by Location, population
order by PercentagePopulationInfected desc

--Countries with Highest Death Count per Populattion

Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT

--Showing ontinents with the highest death count per population

Select continent,Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProjects.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2

--Total population vs Vaccination
--Shows Percentage of Population that has recieved at least one covid vaccine 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths dea
JOIN PortfolioProjects.dbo.CovidVacination vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on partition by in previous query

With PopvsVac ( Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths dea
JOIN PortfolioProjects.dbo.CovidVacination vac
    On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using TEMP TABLE to perform Calculation on Partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths dea
JOIN PortfolioProjects.dbo.CovidVacination vac
    On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProjects.dbo.CovidDeaths dea
Join PortfolioProjects.dbo.CovidVacination vac
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated
