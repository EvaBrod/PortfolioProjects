--Select *
--From PortfolioProject.dbo.CovidDeaths
--Order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--Order by 3,4

--Select Data that we will be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs. Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at Total cases vs. Population
--Shows what percentage of population contracted Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
--Where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected DESC

--Let's look at total deaths by continent:

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--Global Numbers: 

-- Global cases, deaths, and death percentages by date

Select date, SUM(new_cases), SUM( cast(new_deaths as int)), (SUM( cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2

--Global cases, deaths, and death percentages

Select SUM(new_cases), SUM( cast(new_deaths as int)), (SUM( cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE to perform calculation on Pertition By in previous Query

With PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
As
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select * , (RollingPeopleVaccinated/population) *100 as RollingPercentVaccinated
From PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * , (RollingPeopleVaccinated/population) *100 as RollingPercentVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population) *100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * From PercentPopulationVaccinated
