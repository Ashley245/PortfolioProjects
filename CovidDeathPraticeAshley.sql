Select*
From PortforlioProject..CovidDeath
Where continent is not null
Order by 3,4;

Select*
From PortforlioProject..CovidVaccination
Where continent is not null
Order by 3,4;
 
--Select Data to use for project to:

----Compare total cases vs total death-----------------(1)

Select Location, date, total_cases, new_cases,total_deaths, population
From PortforlioProject..CovidDeath
Where continent is not null
Order by 1,2;

--Showing the death percentage as per total cases----------------------------------(2)

Select Location, population,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortforlioProject..CovidDeath
Where continent is not null
Order by 1,2;
--Data on the Countries with Highest Infection rate compared to Population (%)

Select Location, population,MAX(total_cases) as HighestInfectionCount, MAX (total_cases/population)*100 as PercentPopulationInfected
From PortforlioProject..CovidDeath
--Where location like '%kingdom%'
Where continent is not null 
Group By Location,Population
Order by PercentPopulationInfected Desc;

--Showing Countries with the Highest Death Count Per Population(total_death had to be changed to bigint as the sql was not recognising it as numbers)

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortforlioProject..CovidDeath
Where continent is not null Group By Location
Order by TotalDeathCount Desc;
 
---Viewing the total death data via Continent 

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortforlioProject..CovidDeath
--Where location like '%kingdom%'
Where continent is not null
Group By continent
Order by TotalDeathCount Desc;


--Global Numbers
Select Sum(Population) as total_population, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_death, SUM(cast(new_deaths as int))/Sum(new_cases)* 100 as DeathPercentage --total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortforlioProject..CovidDeath
where continent is not null
--Group By population
--Order by 1,2;

--Total Vaccinated people by countries

Select location,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount
From PortforlioProject..CovidVaccination
Where continent is not null
Group By location
Order by TotalVaccineCount Desc;

--Total Vaccinated peoplr by Continent
Select continent,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount
From PortforlioProject..CovidVaccination
Where continent is not null
Group By continent
Order by TotalVaccineCount Desc;

--Showing total Vaccinated and Gdp Correlation by country
Select location,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount, Max(gdp_per_capita) as totalGdpPerCapita
From PortforlioProject..CovidVaccination
Where continent is not null
group by location




--Joining Covid death and Covid Vaccination together

Select *
From PortforlioProject..CovidDeath dea
Join PortforlioProject..CovidVaccination vac
on dea.location=vac.location and  dea.date= vac.date 

--Showing Total Rolling Daily Vaccine in Countries Using joined tables

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, Sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as rolling_daily_vaccine
From PortforlioProject..CovidDeath dea
Join PortforlioProject..CovidVaccination vac
on dea.location=vac.location and  dea.date= vac.date
where dea.continent is not null

--Order by, 2,3

--Create CTE(Common TableExpression &

---Detrmine the percentage of People Vaccinated on a rolling basis
With PopsVac (Continent, location, date, population, new_vaccinations, rolling_daily_vaccine) as

(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as rolling_daily_vaccine
From PortforlioProject..CovidDeath dea
Join PortforlioProject..CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null)
Select *, (rolling_daily_vaccine/population)*100 as rolling_daily_vaccine_percentage
From PopsVac


--Create Temp Table
DROP if table exists
Create Table #PopulationPercentVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_daily_vaccine numeric )

Insert Into #PopulationPercentVaccinated

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as rolling_daily_vaccine
From PortforlioProject..CovidDeath dea
Join PortforlioProject..CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
Select *, (rolling_daily_vaccine/population)*100 as rolling_daily_vaccine_percentage
From #PopulationPercentVaccinated


--Creating View for visualisation

Create View 
PopulationPercentVaccinated 
as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(convert(bigint,vac.new_vaccinations))
over (partition by dea.location order by dea.location, dea.date) as rolling_daily_vaccine
From PortforlioProject..CovidDeath dea
Join PortforlioProject..CovidVaccination vac
on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
Select *
From PopulationPercentVaccinated 

Create View DeathPercentagePerCase as
Select Location, population,total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortforlioProject..CovidDeath
Where continent is not null
--Select *
--From DeathPercentagePerCase

Create View TotalVaccineCountry as 
Select location,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount
From PortforlioProject..CovidVaccination
Where continent is not null
Group By location 
--Select *
--From TotalVaccineCountry

Create View TotalDeathsContinent as 

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortforlioProject..CovidDeath
--Where location like '%kingdom%'
Where continent is not null
Group By continent
Select *
From TotalDeathsContinent

Create View TotalVaccinatedContinent as 
Select continent,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount
From PortforlioProject..CovidVaccination
Where continent is not null
Group By continent

Select *
From TotalVaccinatedContinent 


Create View TotalGdpPerCapitaVacc as
Select location,MAX(cast(total_vaccinations as bigint)) as TotalVaccineCount, Max(gdp_per_capita) as totalGdpPerCapita
From PortforlioProject..CovidVaccination
Where continent is not null
group by location
