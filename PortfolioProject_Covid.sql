Select * 
From PortfolioProject..CovidDeaths$ 
Where continent is not null
order by 3,4

--Select * From PortfolioProject..CovidVaccinations$ 
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$ 
Where continent is not null 
order by 1,2

--Total cases vs Total deaths
Select Location, date, total_cases, (total_cases/population)*100 as Death_percentage  
From PortfolioProject..CovidDeaths$ 
Where location like '%India%' 
and continent is not null
order by 1,2

-- Total cases vs Population
Select Location, date, Population, total_cases, (total_cases/population)*100 as Infection_percentage  
From PortfolioProject..CovidDeaths$ 
--Where location like '%India%' 
Where continent is not null
order by 1,2


-- Infection rates
Select Location, Population, MAX(total_cases) as HigestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected  
From PortfolioProject..CovidDeaths$ 
--Where location like '%India%'
Group by location, population
order by PercentagePopulationInfected desc


--Countries with highest deaths per capita
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount  
From PortfolioProject..CovidDeaths$ 
--Where location like '%India%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Total deaths by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage  
From PortfolioProject..CovidDeaths$ 
--Where location like '%India%' 
Where continent is not null
--Group by date
order by 1,2


--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


--Using CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using temp table
Drop Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create view to store data for visualizations

use portfolioproject
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) 
OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select * 
From PercentPopulationVaccinated
