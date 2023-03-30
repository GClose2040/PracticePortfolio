Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows liklihood of dying if you contract covid in you contry
SELECT Location, date, CAST(total_cases AS bigint) AS Total_Cases, CAST(total_deaths AS bigint) AS Total_Deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
ORDER BY 1, 2;
-- Had to convert total cases and total deaths to integers in order to find the percentages.
-- Since population is so high I needed to cast the figures into bigints


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT Location, date, Population, CAST(total_cases AS bigint) AS Total_Cases,  (CAST(total_cases AS float) / Population) * 100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
ORDER BY 1, 2;

-- Look at countries with highest infection rate compared to the population

SELECT Location, Population, MAX(cast(total_cases as bigint)) as HighestInfectionCount,  MAX((CAST(total_cases AS float) / Population) * 100) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location, Population
ORDER BY InfectedPercentage desc

-- Showing Countries with Highest Desath Count per Population

SELECT Location, Max(cast(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
ORDER BY TotalDeathCount desc

-- Break down by continent

SELECT Location, Max(cast(Total_deaths as bigint)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null and location not like '%income%'
Group by Location
ORDER BY TotalDeathCount desc

-- Global numbers

SELECT SUM(New_Cases) as TotalNewCases, SUM(New_Deaths) as TotalNewDeaths, 
Case When Sum(new_cases)>0
	Then(Sum(New_Deaths)/Sum(New_Cases))*100 
	Else Null
End as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%' 
Where continent is not null
ORDER BY 1, 2;

--Looking at totla population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Loacation nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3