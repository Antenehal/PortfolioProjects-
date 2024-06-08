select * 
from CovidDeaths
where continent is not null
order by 3,4

--select * from covidvaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2

--looking at total cases Vs Population

select location,date,Population,total_cases,(total_cases/population)*100 as infectedpercentage
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2



--looking at highest infection rate comparedto population

select location,Population,max(total_cases)as HighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like'%states%'
group by location, Population
order by PercentPopulationInfected desc

--countries with highest death count 

select location,max(cast( total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like'%states%' 
where continent is not null
group by location
order by TotalDeathCount desc 


select continent,max(cast( total_deaths as int))as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like'%states%' 
where continent is not null
group by continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS

select sum(new_cases),SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(NEW_DEATHS AS INT))/SUM(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where Continent is not null
--group by date
order by 1,2

--looking at total Population vs Vaccinations

select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date)
as RollingPeopleVaccinated, --(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac (continet, location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	 where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

Drop table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
continent nvarchar(255),
location  nvarchar(255),
date datetime,
Population numeric,
 new_Vaccinations numeric,
 RollingPeoplevaccinated numeric
 )

 Insert into #PercentpopulationVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	-- where dea.continent is not null
order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
from #PercentpopulationVaccinated


--creating View to store data for later visualization

Create View PercentpopulationVaccinated as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(convert(int,vac.new_vaccinations)) over (partition by dea.location,dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
     on dea.location = vac.location 
	 and dea.date = vac.date
	where dea.continent is not null
--order by 2,3

select*
from PercentpopulationVaccinated