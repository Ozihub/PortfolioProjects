Select *
From NewProject..CovidDeaths2
Where continent is not null 
order by 3,4

Select location, date, total_cases, new_cases, population
From NewProject..CovidDeaths2
Where continent is not null 
order by 1, 2

--TOTAL CASES VS TOTAL DEATHS

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From NewProject..CovidDeaths2
Where location like '%states%'
and continent is not null 
order by 1, 2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From NewProject..CovidDeaths2
Where location like '%nigeria%'
and continent is not null 
order by 1, 2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED WITH POPULATION

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From NewProject..CovidDeaths2
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--COUNTRIES WITH HIGHEST DEATHCOUNT PER POPULATION

Select location, max(total_deaths) as TotalDeathCount
From NewProject..CovidDeaths2
where continent is not null
Group by location
order by TotalDeathCount desc
 
 --BREAKING THINGS DOWN BY CONTINENT
 --Showing continents with the highest death count per population

Select continent, max(total_deaths) as TotalDeathCount
From NewProject..CovidDeaths2
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From NewProject..CovidDeaths2
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--TOTAL POPULATION VS VACCINATIONS
--Shows percentange of population that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From NewProject..CovidDeaths2 dea
Join NewProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From NewProject..CovidDeaths2 dea
Join NewProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From NewProject..CovidDeaths2 dea
Join NewProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store dat later for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From NewProject..CovidDeaths2 dea
Join NewProject..CovidVaccinations2 vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From #PercentPopulationVaccinated