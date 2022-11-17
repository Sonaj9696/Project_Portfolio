select *
from PortfolioProject..covidDeaths
order by 3,4

--select *
--from PortfolioProject..covidVaccinations
--order by 3,4

-- select data that we are going to be using for project

select location, date,total_cases,new_cases,total_deaths,population
from portfolioproject..covidDeaths
order by 1,2

--Looking at Total cases VS Total deaths
-- Showing likelihood of dying if you contract covid in your country
select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..covidDeaths
where location like '%India%'
order by 1,2

-- Looking at total cases vs population
--shows that percentage of population got covid

select location, date, total_cases,population, (total_cases/population)*100 as populationPercentGotCovid
from PortfolioProject..covidDeaths
where location like '%India%'
order by 1,2

-- for all countries
select location, date, total_cases,population, (total_cases/population)*100 as populationPercentGotCovid
from PortfolioProject..covidDeaths
--where location like '%India%'
order by 1,2

-- Looking at countries with Highest Infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
--where location like '%India%'
group by location, population
order by PercentPopulationInfected desc

--for India
select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..covidDeaths
where location like '%India%'
group by location, population
order by PercentPopulationInfected desc

--Showing countries with Highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..covidDeaths
--where location like '%china%'
where continent is not null
group by location
order by TotalDeathCount desc


--Let's break things down by continent

--not including null values
select continent, max(cast(total_deaths as int)) as Total_Deaths_count
from PortfolioProject..covidDeaths
where continent is not null
group by continent
order by Total_Deaths_count desc

--including null values
select location,max(cast(total_deaths as int)) as Total_Deaths_count
from PortfolioProject..covidDeaths
where continent is null
group by location
order by Total_Deaths_count desc


-- Global Numbers
select date, sum(cast(new_cases as int)) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..covidDeaths
--where continent is not null
--group by date
order by 1,2

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
from PortfolioProject..covidDeaths
where continent is not null
--group by date
order by 1,2



select * 
from PortfolioProject..covidVaccinations

--Looking Total Population vs Vaccinations
--joins

select * 
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


with PopVsVac (continent,location, date, population,New_vaccinations,Rolling_People_vaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as Rolling_People_vaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_vaccinated/Population)*100
from PopVsVac



-- Tem Table
drop table if exists #Percent_Population_Vaccinated

create table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_vaccinated numeric
)



insert into #Percent_Population_Vaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as Rolling_People_vaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (Rolling_People_vaccinated/Population)*100
from #Percent_Population_Vaccinated



--Creating view to store data for later visualizations

create view Percent_Population_vaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.Location order by dea.location,dea.date) as Rolling_People_vaccinated
from PortfolioProject..covidDeaths dea
join PortfolioProject..covidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *
from Percent_Population_vaccinated
