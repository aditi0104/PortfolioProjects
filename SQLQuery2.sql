select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as deathCovidPercentage, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total cases by percentage
-- What percentage of population got infected by Covid

select Location, date, total_cases, population, (total_cases / population) * 100 as percentPopulationAffected
from CovidDeaths
where location = 'India'
order by 2


--Highest infection rates compared to population not per date but overall
select Location, population, max(total_cases) as HighestInfectedCount, max((total_cases / population)) * 100 as percentPopulationAffected
from CovidDeaths
--where location = 'India'
group by location, population
order by percentPopulationAffected desc


--highest death count per country

select location, population, max(cast(total_deaths as int)) as deathCount
from CovidDeaths
group by location, population
order by deathCount desc

-- total cases per continent

select continent, max(total_cases) as totalcases
from CovidDeaths
where continent is not null
group by continent
order by totalcases desc

-- total death per continent
select continent, max(cast(total_deaths as int)) as totaldeathspercontinent
from CovidDeaths
where continent is not null
group by continent
order by totaldeathspercontinent desc


--global numbers per day

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--total cases, total deaths and death percentage across the globle
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


-- total number of people who have been vaccinated in the world
-- using cte

with cte ( continent, location, date, population, new_vaccinations, vaccinationPerCountry)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as vaccinationPerCountry
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (max(vaccinationPerCountry)/population) * 100 as vaccinationpercentage
from cte

--using temp table

DROP TABLE IF EXISTS #vaccinatedpercentage
CREATE TABLE #vaccinatedpercentage(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Populations numeric,
New_vaccinations numeric,
totalvaccinated numeric
)

INSERT INTO #vaccinatedpercentage
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as vaccinationPerCountry
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (totalvaccinated/Populations) * 100 as vaccinationpercentage
from #vaccinatedpercentage

--creation of view for visualizations

CREATE VIEW PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by vac.location order by vac.location, vac.date) as vaccinationPerCountry
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from PercentagePopulationVaccinated