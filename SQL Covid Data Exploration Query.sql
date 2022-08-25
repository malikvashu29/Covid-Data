ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN total_deaths int

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN total_cases int

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN population bigint

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN location varchar(20)


ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN Total_deaths int

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN new_deaths int

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN new_cases int

ALTER TABLE [Covid Data]..[covid deaths n]
ALTER COLUMN date date

ALTER TABLE [Covid Data]..[covid vaccination n]
ALTER COLUMN date date


select * 
from [Covid Data]..[covid deaths n]
order by 3, 4

select location 
from [Covid Data]..[covid deaths n]
where continent = ''
--order by 3, 4

select continent,location 
from [Covid Data]..[covid deaths n]
where date = '2020-06-29'
--order by 3, 4

select * 
from [Covid Data]..[covid deaths n]
where location not in (select continent from [Covid Data]..[covid deaths n])
order by 3, 4

--select * from [Covid Data]..[covid vaccination n]
--order by 3, 4

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population 
from [Covid Data]..[covid deaths n]
order by 1,2

-- Looking at total cases vs toal deaths
--select location, date, total_cases, total_deaths, (CONVERT(int, total_deaths)/CONVERT(int,total_cases))*100 as DeathPercentage
select location, date, total_cases, total_deaths, (CONVERT(decimal(15,6),total_deaths)/CONVERT(decimal(15,6),total_cases))*100 as DeathPercentage
from [Covid Data]..[covid deaths n]
where total_cases != 0
order by 1,2

-- Looking at total cases vs population
-- The percentage of people got infected
select location, date, total_cases, population, (CONVERT(decimal(20,10), total_cases)/CONVERT(decimal(20,10), population))*100 as InfectedPercentageOfopulation
from [Covid Data]..[covid deaths n]
where location like '%Asia%'
order by 1,2

-- Looking at countires with highest infection rate compared to population
select location,population,  MAX(total_cases) as Highest_Infection_Count,  MAX((CONVERT(decimal(20,10), total_cases)/CONVERT(decimal(20,10), population)))*100 as InfectedPercentageOfopulation
from [Covid Data]..[covid deaths n]
--where location like '%Asia%'
group by location, population
order by InfectedPercentageOfopulation desc


-- Looking at Countries with hghest death count per population
select location, max(Total_deaths) as TotalDeathCount
from [Covid Data]..[covid deaths n]
where location not in (select continent from [Covid Data]..[covid deaths n]) and continent != ''
group by location
order by TotalDeathCount desc

-- Looking at Data, grouped by Continents

-- Showing the continets with highest death counts
select location, max(Total_deaths) as TotalDeathCount
from [Covid Data]..[covid deaths n]
where continent =''
group by location
order by TotalDeathCount desc

-- Global Numbers
select  date, sum(new_cases) as total_cases,sum(new_deaths) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from [Covid Data]..[covid deaths n]
where continent !='' and  new_cases > 0 --(select sum(new_cases) from [Covid Data]..[covid deaths n]) > 0 --total_cases != 0 and 
group by date
order by 1,2


select   sum(new_cases) as total_cases , sum(new_deaths) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as DeathPercentage
from [Covid Data]..[covid deaths n]
where continent !='' --and  new_cases > 0 --(select sum(new_cases) from [Covid Data]..[covid deaths n]) > 0 --total_cases != 0 and 
--group by date
order by 1,2


--Covid vaccination table
Select *
From [Covid Data]..[covid vaccination n]


--Joining Covid Deaths and Covid Vaccination Table
Select *
From [Covid Data]..[covid deaths n] dea
Join [Covid Data]..[covid vaccination n] vac
	on dea.location = vac.location
	and dea.date = vac.date

--Looking at total population vs vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_till_date
From [Covid Data]..[covid deaths n] dea
Join [Covid Data]..[covid vaccination n] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--group by dea.location
order by 2,3




-- USE CTE(common table expression)
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Vaccinated_till_date)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_till_date

From [Covid Data]..[covid deaths n] dea
Join [Covid Data]..[covid vaccination n] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--group by dea.location
--order by 2,3
)
Select *, ((Vaccinated_till_date)/cast(Population as float))*100
from PopvsVac


-- Using Temp Table
drop table if exists Percent_Population_Vaccinated
Create Table Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
Vaccinated_till_date bigint
)

Insert Into Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_till_date

From [Covid Data]..[covid deaths n] dea
Join [Covid Data]..[covid vaccination n] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--group by dea.location
--order by 2,3

Select *, ((Vaccinated_till_date)/Population)*100
from Percent_Population_Vaccinated


-- Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Vaccinated_till_date

From [Covid Data]..[covid deaths n] dea
Join [Covid Data]..[covid vaccination n] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent != ''
--group by dea.location
--order by 2,3



Select * 
From PercentPopulationVaccinated