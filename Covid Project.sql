select * from CovidPortfolio_Project.dbo.Total_Death
select * from CovidPortfolio_Project.dbo.Total_Vaccinated
--Total Rows--
select count(*)As Total_Rows from CovidPortfolio_Project..Total_Vaccinated
select count(*)As Total_Rows from CovidPortfolio_Project..Total_Death

select location, sum(Population)as population from CovidPortfolio_Project.dbo.Total_Death group by location having sum(Population) > 10000000000 order by Population desc


select * from CovidPortfolio_Project.dbo.Total_Death
where continent is not null
order by 3,4
select * from CovidPortfolio_Project.dbo.Total_Vaccinated
order by 3,4

--Select the data which we required--
select
	location, date, total_cases, new_cases,Total_Deaths,Population
		from CovidPortfolio_Project..Total_Death
			order by 1,2;

--Total Case vs total death--
select location, date,total_cases,Total_Deaths,(total_cases/Total_Deaths) Total_Death_Per 
from CovidPortfolio_Project..Total_Death where location like '%india%'
ORDER BY 1,2;

--Total cases vs populations--
select location,date,total_cases,population, (total_cases/Population)*100 from CovidPortfolio_Project..Total_Death 
--where location like '%India%'--
order by 1,3

--countries with highest infection rate compared to population--
select distinct location, Population, max(total_cases)as Total_Cases,max((total_cases/Population)*100) Infection_Rate 
from CovidPortfolio_Project..Total_Death group by location,Population order by Infection_Rate desc

--Showing the countries with highest death count per population-- 
select distinct location, Population,Total_Deaths, avg(Total_Deaths/Population) as Death_Per from CovidPortfolio_Project..Total_Death group by location, Population,Total_Deaths order by Death_Per desc

select distinct location,Population,max(cast(Total_Deaths as int))as Total_Death,avg(cast(Total_Deaths as int)/Population) as Death_Per 
from CovidPortfolio_Project..Total_Death group by location, Population, Total_Deaths order by Death_Per desc

select distinct location , max(cast(Total_Deaths as int))Total_Deaths from CovidPortfolio_Project..Total_Death 
where continent is not null 
group by location order by Total_Deaths desc

--Continets wise informations--
select distinct continent , max(cast(Total_Deaths as int))Total_Deaths from CovidPortfolio_Project..Total_Death 
where continent is not null 
group by continent order by Total_Deaths desc;

select distinct location , max(cast(Total_Deaths as int))Total_Deaths from CovidPortfolio_Project..Total_Death 
where continent is null 
group by location order by Total_Deaths desc;


--Showing the continents with highest death count
select distinct continent , max(cast(Total_Deaths as int))Total_Deaths from CovidPortfolio_Project..Total_Death 
where continent is not null 
group by continent order by Total_Deaths desc;

--Beaking global numbers--
select Date, sum(new_cases)New_Cases, SUM(cast(new_deaths as int))New_Death ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Total_Death_Per
from CovidPortfolio_Project..Total_Death 
where continent is not null
group by Date
order by Total_Death_Per asc

select sum(new_cases)New_Cases, SUM(cast(new_deaths as int))New_Death ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Total_Death_Per
from CovidPortfolio_Project..Total_Death 
where continent is not null
order by Total_Death_Per asc


--Join Covid vaccination table and total death table--
select * from CovidPortfolio_Project.dbo.Total_Death a
join CovidPortfolio_Project.dbo.Total_Vaccinated b
	on a.location=b.location
	and a.date = b.date

--Looking total population vs total vaccination--

--CTE TABLE--
with PopVsVac (Continent,Location,Date,Population,new_vaccinations,People_Vaccinated)
as
(
select a.Continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(bigint,b.total_vaccinations)) over (partition by a.location order by a.location, a.date)
as People_Vaccinated
from CovidPortfolio_Project.dbo.Total_Death a
join CovidPortfolio_Project.dbo.Total_Vaccinated b
	on a.location=b.location
	and a.date = b.date
	where a.continent is not null
	--order by 2,3
)
select *,(People_Vaccinated/population)
from PopVsVac

--TEMP TABLE
create table PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
People_Vaccinated numeric
);

insert into PercentPeopleVaccinated
select a.Continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(bigint,b.total_vaccinations)) over (partition by a.location order by a.location, a.date)
as People_Vaccinated
from CovidPortfolio_Project.dbo.Total_Death a
join CovidPortfolio_Project.dbo.Total_Vaccinated b
	on a.location=b.location
	and a.date = b.date
	where a.continent is not null
	--order by 2,3

select *,(People_Vaccinated/population) as Percentvaccinated
from PercentPeopleVaccinated


drop table PercentPeopleVaccinated

--Creating view to store data for later visualizations--
create view PercentPeopleVaccinated as 
select a.Continent, a.location, a.date, a.population, b.new_vaccinations,
sum(convert(bigint,b.total_vaccinations)) over (partition by a.location order by a.location, a.date)
as People_Vaccinated
from CovidPortfolio_Project.dbo.Total_Death a
join CovidPortfolio_Project.dbo.Total_Vaccinated b
	on a.location=b.location
	and a.date = b.date
	where a.continent is not null
	--order by 2,3