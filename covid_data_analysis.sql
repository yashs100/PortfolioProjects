--Select *
--	From PortfolioProject..CovidDeaths
--	order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT Location, 
       date, 
       total_cases, 
       total_deaths,
	   (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%India%'
ORDER BY Location, date

-- Looking at Total Cases vs Population

SELECT Location, 
       date, 
       total_cases, 
       population,
	   (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
ORDER BY Location, date


-- Looking at Countries with highest infection rate compared to Population
SELECT Location,   
       population,
	   MAX(total_cases) as HighestInfectionCount,
	   MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, Population
ORDER BY PercentagePopulationInfected desc


-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population
SELECT continent,   
	   MAX(cast(total_deaths as int)) as HighestDeathCount,
	   MAX((cast(total_deaths as int)/population))*100 as PercentagePopulationDeaths
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by continent
ORDER BY HighestDeathCount desc



-- Global Numbers

Select SUM(new_cases) as TotalNewCases, SUM(cast (new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from PopvsVac


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentageofPeopleVaccinated
from #PercentPopulationVaccinated


-- Creating Views to store data for late vizualizations
Use PortfolioProject;
GO

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.Date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Create View GlobalNumbers as
Select SUM(new_cases) as TotalNewCases, SUM(cast (new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--order by 1,2


Create View ContinentDeathCount as
SELECT continent,   
	   MAX(cast(total_deaths as int)) as HighestDeathCount,
	   MAX((cast(total_deaths as int)/population))*100 as PercentagePopulationDeaths
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Where continent is not null
Group by continent
--ORDER BY HighestDeathCount desc

Create View HighestInfectionRatePerCountry as
SELECT Location,   
       population,
	   MAX(total_cases) as HighestInfectionCount,
	   MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, Population
--ORDER BY PercentagePopulationInfected desc


Create View TotalCasesvsPop as
SELECT Location, 
       date, 
       total_cases, 
       population,
	   (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
--ORDER BY Location, date


Create View CasesVsDeaths as
SELECT Location, 
       date, 
       total_cases, 
       total_deaths,
	   (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%India%'
--ORDER BY Location, date