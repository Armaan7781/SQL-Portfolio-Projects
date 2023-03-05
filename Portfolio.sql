SELECT * FROM [Portfolio Project]..[COVID DEATHS]	
WHERE CONTINENT IS NOT NULL
order by 3,4

SELECT *
FROM [Portfolio Project]..Covid_Vaccination
order by 3,4


 -- Select Data That we are going to be Using

select Location, Date, new_cases, total_deaths,population, continent
FROM [Portfolio Project]..[COVID DEATHS]
order by 1,2

-- Looking at Total_cases vs Total Deaths
-- shows the likelyhood if you contract covid in your country

select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 [% of Deaths]
FROM [Portfolio Project]..[COVID DEATHS]
where location LIKE '%india%'
order by 1,2


--looking at Total_cases vs Population
-- Show what percentage got stucked 

select Location, Date, total_cases, population, (total_cases/population)*100 [Death Percentage]
FROM [Portfolio Project]..[COVID DEATHS]
--where location LIKE '%india%'
order by 1,2


-- looking at countries with highest infection rate compared to population

select Location,population, Continent, max(cast(total_deaths as int)) [Highest Infection Count],round((max((total_deaths/population))*100),2) [% of PopulatioN Infected]
FROM [Portfolio Project]..[COVID DEATHS]
--where location LIKE '%india%'
group by location, population, continent
order by 4 desc

-- SHOWING countries with highest death count per population 

select Location, MAX(cast(total_deaths as int))TotalDeathCount
FROM [Portfolio Project]..[COVID DEATHS]
--where location LIKE '%india%'
WHERE CONTINENT IS NOT NULL
group by Location
order by 2 DESC

--LET'S BREAK DOWN THING DOWN BY CONTINENT 

-- Showing Continent with highest Death Counts

select continent , MAX(cast(total_deaths as int))TotalDeathCount
FROM [Portfolio Project]..[COVID DEATHS]
--where location LIKE '%india%'
WHERE CONTINENT IS  not NULL
group by continent
order by 2 DESC




-- GLOBAL Numbers

select SUM(NEW_CASES) [NEW CASES], SUM(CAST(NEW_DEATHS AS INT))[NEW DEATHS], SUM(CAST(NEW_DEATHS AS INT))/ SUM(NEW_CASES)*100 AS [DEATH%]
FROM [Portfolio Project]..[COVID DEATHS]
--where location LIKE '%global%'
WHERE CONTINENT IS NOT NULL
--GROUP BY DATE 
order by 1,2


-- looking at Total Population vs Vaccination

-- Use CTE 

With POPvsVAC (Continent, Location, Date, Population,New_vaccinatons, [Rolling People Vaccination])
as 
(
SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.population, VACCIN.new_vaccinations,
sum(Convert(int,VACCIN.new_vaccinations)) over (partition by deaths.location order by deaths.location , deaths.date) 
as [Rolling People Vaccination]FROM [Portfolio Project]..Covid_Vaccination  AS VACCIN
--([Rolling People Vaccination]/population)*100
JOIN [Portfolio Project]..[COVID DEATHS] Deaths
	on Deaths.location = Vaccin.Location
    and  Deaths.date = Vaccin.Date
    where deaths.continent is not null
--order by 2,3
) 
select *,(Round([Rolling People Vaccination]/Population,2))*100 
from POPvsVAC


--TEMP TABLE
DROP TABLE IF EXISTS #PeoplePopulationVaccination
CREATE TABLE #PeoplePopulationVaccination
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
population numeric,
New_Vaccination numeric,
[Rolling People Vaccination] numeric
)
INSERT INTO #PeoplePopulationVaccination 
SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.population, VACCIN.new_vaccinations,
sum(Convert(int,VACCIN.new_vaccinations)) over (partition by deaths.location order by deaths.location , deaths.date) 
as [Rolling People Vaccination]FROM [Portfolio Project]..Covid_Vaccination  AS VACCIN
--([Rolling People Vaccination]/population)*100
JOIN [Portfolio Project]..[COVID DEATHS] Deaths
	on Deaths.location = Vaccin.Location
    and  Deaths.date = Vaccin.Date
    where deaths.continent is not null
--order by 2,3
select *,(Round([Rolling People Vaccination]/Population,2))*100 
from #PeoplePopulationVaccination


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create view PercentPopulationVaccinated as

SELECT Deaths.continent, Deaths.Location, Deaths.date, Deaths.population, VACCIN.new_vaccinations,
sum(Convert(int,VACCIN.new_vaccinations)) over (partition by deaths.location order by deaths.location , deaths.date) 
as [Rolling People Vaccination]FROM [Portfolio Project]..Covid_Vaccination  AS VACCIN
--([Rolling People Vaccination]/population)*100
JOIN [Portfolio Project]..[COVID DEATHS] Deaths
	on Deaths.location = Vaccin.Location
    and  Deaths.date = Vaccin.Date
    where deaths.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated