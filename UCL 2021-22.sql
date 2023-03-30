-- Discover the weak points of any team.
-- Suggest players need to be sold, based on performance analysis.
-- Nominate Player of the season


-- First Lets Drop Serial num column 

alter table [UCL 2021-22]..Attacking
drop column Serial

---------------------------------------------------------------------------------------------------------

-- Now Lets Create a list of weak players per Category

 --- Attacking
 
 -- First Create following column
alter table [UCL 2021-22 ]..Attacking
add [Assists per match] decimal (8,2);

update [UCL 2021-22 ]..Attacking
set [Assists Per Match] = (Assists/match_played)


WITH CTE_Attacking AS (
    SELECT 
        Player_Name, Club, Position, Assists, Corner_Taken, Offsides, Dribbles, [Assists per match],
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY Assists asc, Dribbles asc, Offsides desc,[Assists Per Match] ASC) AS row_num
    FROM [UCL 2021-22]..Attacking
    WHERE Position IN ('Midfielder', 'Forward')
)
SELECT 
    Player_Name, Club, Position, Assists, Corner_Taken, Offsides, Dribbles, [Assists per match]
FROM CTE_Attacking
WHERE row_num = 1
order by Assists asc, Dribbles asc, Offsides desc,[Assists Per Match] ASC




--------------------------------------------------------------------------------------------------------------
 
 -- Attempts 

 
--alter table [UCL 2021-22]..Attempts
--drop column Serial

--First Create Shot Accuracy Column:

alter table [UCL 2021-22]..Attempts
add [Shot Accuracy] decimal(5,2);

update [UCL 2021-22]..Attempts
set [Shot Accuracy] = 
(
 on_target/ total_attempts
)


WITH CTE_Attempts AS (
    SELECT 
        Player_Name, Club, Position, Total_attempts, on_target, off_target, blocked, [shot Accuracy],
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY on_target asc,Total_attempts asc,[shot Accuracy] asc) AS row_num
    FROM [UCL 2021-22]..Attempts
    WHERE Position IN ('Midfielder', 'Forward')
)
SELECT 
     Player_Name, Club, Position, Total_attempts, on_target, off_target, blocked, [shot Accuracy]
FROM CTE_Attempts
WHERE row_num = 1
order by on_target asc,Total_attempts asc ,[shot Accuracy] asc

---------------------------------------------------------------------------------------------

-- Defense 

--alter table [UCL 2021-22]..Defense
--drop column Serial

WITH CTE_Defense AS (
    SELECT 
        Player_Name, Club, Position, balls_recoverd, tackles, t_won,t_lost,clearance_attempted,
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY tackles asc,T_won asc,clearance_attempted asc,balls_recoverd asc) AS row_num
    FROM [UCL 2021-22]..Defense
    WHERE Position IN ('Defender','Midfielder')
	and match_played > 5
)
SELECT 
     Player_Name, Club, Position, balls_recoverd, tackles, t_won,t_lost,clearance_attempted
FROM CTE_Defense
WHERE row_num = 1
ORDER BY tackles asc,T_won asc,clearance_attempted asc,balls_recoverd asc

--------------------------------------------------------------------------------------------------

-- Distribution

--alter table [UCL 2021-22]..Distribution
--drop column Serial

WITH CTE_Distribution AS (
    SELECT 
        Player_Name, Club, Position, pass_accuracy, pass_attempted, pass_completed,cross_accuracy,
		cross_attempted,cross_complted,freekicks_taken,
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY  pass_accuracy asc,cross_accuracy asc,pass_completed asc,cross_complted asc) AS row_num
    FROM [UCL 2021-22]..Distribution
   WHERE Position <> 'GoalKeeper' --('Defender','Midfielder')
)
SELECT 
     Player_Name, Club, Position, pass_accuracy, pass_attempted, pass_completed,cross_accuracy,
		cross_attempted,cross_complted,freekicks_taken
FROM CTE_Distribution
WHERE row_num = 1

--------------------------------------------------------------------------------------------------------

--GK

--alter table [UCL 2021-22]..GK
--drop column Serial


-- First Create following Columns 
alter table [UCL 2021-22]..GK
add [Total Shots Faced] int;

update [UCL 2021-22]..GK
set [Total Shots Faced] = (saved+ conceded)

alter table [UCL 2021-22]..GK
add [Concede percentage] decimal(5,2);

update [UCL 2021-22]..GK
set [Concede percentage] = (conceded / [Total Shots Faced])

alter table [UCL 2021-22]..GK
add [Saved percentage] decimal(5,2);

update [UCL 2021-22]..GK
set [Saved percentage] = (saved / [Total Shots Faced])
 
alter table [UCL 2021-22]..GK
 drop column [Concede_Percentage] 

 WITH CTE_GK AS (
    SELECT 
        Player_Name, Club, Position, saved, conceded, saved_penalties,cleansheets,[punches made],
		[Total Shots Faced],[Saved percentage],[Concede percentage],
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY cleansheets asc, [Saved percentage] asc,Saved asc 
		) AS row_num
    FROM [UCL 2021-22]..GK
)
SELECT 
     Player_Name, Club, Position, saved, conceded, saved_penalties,cleansheets,[punches made],
		[Total Shots Faced],[Saved percentage],[Concede percentage]
FROM CTE_GK
WHERE row_num = 1
order by cleansheets asc, [Saved percentage] asc,Saved asc 


---------------------------------------------------------------------------------------------------------

---- Goals


--alter table [UCL 2021-22]..Goals
--drop column Serial

-- Goals From Forward

WITH CTE_Goals AS (
    SELECT 
        Player_Name,Club, Position, Goals, right_foot, left_foot,headers,others,inside_area,outside_areas,
		penalties,
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY Goals asc) AS row_num
    FROM [UCL 2021-22]..Goals
    WHERE Position in ('Forward')
	--and match_played > 5
)
SELECT 
     Player_Name, Club, Position, Goals, right_foot, left_foot,headers,others,inside_area,outside_areas,penalties
FROM CTE_Goals
WHERE row_num = 1
ORDER BY Goals asc

-- Let's Consider Midfielders Now

WITH CTE_Goals AS (
    SELECT 
        Player_Name,Club, Position, Goals, right_foot, left_foot,headers,others,inside_area,outside_areas,
		penalties,
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY Goals asc) AS row_num
    FROM [UCL 2021-22]..Goals
    WHERE Position in ('Midfielder')
	--and match_played > 5
)
SELECT 
     Player_Name, Club, Position, Goals, right_foot, left_foot,headers,others,inside_area,outside_areas,penalties
FROM CTE_Goals
WHERE row_num = 1
ORDER BY Goals asc


--------------------------------------------------------------------------------------------------------

-- KEY STATS


--FIRST CREATE FOLLOWING COLUMNS

ALTER TABLE [UCL 2021-22]..['KEY STATS']
ADD [G+A] INT;

UPDATE [UCL 2021-22]..['KEY STATS']
SET [G+A] = (goals+assists)

--G+90


ALTER TABLE [UCL 2021-22]..['KEY STATS']
ADD [Goals Per 90] decimal(5,2);

UPDATE [UCL 2021-22]..['KEY STATS']
SET [Goals Per 90] = (goals/minutes_played)*90;

WITH CTE_KeyStats AS (
    SELECT 
        Player_Name,Club, Position, Goals,assists, [G+A],distance_covered,minutes_played,[Goals Per 90],
        ROW_NUMBER() OVER (PARTITION BY Club ORDER BY Goals,assists,Position, [G+A]asc) AS row_num
    FROM [UCL 2021-22]..['Key Stats']
    WHERE Position in ('Forward', 'midfielder')
	and minutes_played > 75
)
SELECT 
     Player_Name, Club, Position, Goals, assists, [G+A],distance_covered,minutes_played,[Goals Per 90]
FROM CTE_KeyStats
WHERE row_num = 1
ORDER BY Goals asc, [G+A], [Goals Per 90]



-------------------------------------------------------------------------------------------------------------

-- Discover the weak points of any team.
----------------------------------------------------------------------------------------------

--Attacking 

CREATE TABLE #Temp_Attack
(Club nvarchar(255),
[Total Players] int,
[Total Offsides] int,
[Total Dribbles] int,
[Total Corners] int
)

--with cte_attack as
insert into #Temp_Attack
select club,count(player_name),
Sum(Assists) as [Total Assists],sum(offsides)[Total Offsides], sum(dribbles)[Total Dribbles],
Sum(corner_taken) [Total Corners]
from [UCL 2021-22]..Attacking
group by club
order by [Total Assists],[Total Dribbles],[Total Offsides] desc, [Total Corners]


--select *
--from cte_attack
--order by [Total Assists],[Total Dribbles], [Total Offsides] desc


---------------------------------------------------------------------------------------------------

-- Attempts

SELECT * 
FROM [UCL 2021-22]..Attempts;


with cte_attempt as 
(
select club, 
count(player_name) [Total Players],sum(total_attempts) [Total Attempts],sum(on_target) [On Target],
	   sum(off_target)[Off Target], sum(blocked) [Blocked], (ROUND(AVG([shot Accuracy]),2)) [SHOT ACCURACY]
from [UCL 2021-22]..Attempts
GROUP BY CLUB
----ORDER BY [Total Attempts] desc, [On Target] desc, [SHOT ACCURACY] desc, Blocked asc

)

select *
from cte_attempt
ORDER BY [Total Attempts]asc, [On Target]asc, [SHOT ACCURACY]asc, Blocked desc
--------------------------------------------------------------------------------------------------------------

-- DEFENSE

SELECT *
FROM  [UCL 2021-22]..Defense;

with cte_def as 
(
Select club, count(player_name) [Total Players], SUM(Balls_recoverd)[Total Balls Recovered],
SUM(tackles)[Total Tackles Attempted],
SUM(t_won)[Total Tackles Won],SUM(clearance_attempted)[Total Clearance Attempted],
(Round(sum(t_won)/sum(tackles),2)) [Tackle Win Rate]
FROM  [UCL 2021-22]..Defense
group by club
--order by [Tackle Win Rate] desc,[Total Tackles Won] desc,
--[Total Balls Recovered] desc,[Total Clearance Attempted] desc
)


select *
from cte_def
order by [Tackle Win Rate]asc,[Total Tackles Won] asc,
[Total Balls Recovered] asc,[Total Clearance Attempted] asc
----------------------------------------------------------------------------------------

-- Distribution

select * 
from [UCL 2021-22]..Distribution

select club,count(player_name) [Total Players],(ROUND(avg(pass_accuracy),2) )[Avg Pass Accuracy],
sum(pass_attempted) [Total Pass Attempted],sum(pass_completed) [Total Passses Completed],
sum(cross_attempted) [Total crosses Attempted],sum(cross_complted) [Total Crosses Completed],
(ROUND(avg(cross_accuracy),2) )[Avg Cross Accuracy],sum(freekicks_taken) [Total Freekicks Taken]
from [UCL 2021-22]..Distribution
Group by club
ORDER BY [Avg Pass Accuracy] DESC, [Avg Cross Accuracy] DESC, 
[Total Passses Completed] DESC, [Total Crosses Completed] DESC

-------------------------------------------------------------------------------------------------
 
--- GK

SELECT *
FROM [UCL 2021-22]..GK

Select club,count(player_name) [Total Players],SUM([Total Shots Faced]) [Total Shots Faced],
SUM(saved) [Total Saves],SUM(conceded) [Total Conceded],(ROUND(avg([Saved percentage]),2) )[Avg Shots Saved %],
(ROUND(avg([Concede percentage]),2) )[Avg Shots Conceded %],SUM(cleansheets) [Total Cleansheets],
SUM([punches made]) [Total Punches Made],SUM(saved_penalties) [Total Penalty Saves]
FROM [UCL 2021-22]..GK
GROUP BY club
order by [Total Cleansheets] desc, [Avg Shots Saved %] desc , [Total Saves] desc ,
[Total Penalty Saves] desc

----------------------------------------------------------------------------------------------

-- Goals

select *
from [UCL 2021-22]..Goals

select club,count(player_name) [Total Players], SUM(Goals) [Total Goals], 
SUM(right_foot) [Total Right Foot Goals], SUM(left_foot) [Total Left Foot Goals],
SUM(headers) [Total Header Goals],SUM(others) [Total  other Goals],
SUM(inside_area) [Total Goals From Inside D],
SUM(outside_areas) [Total Goals From Outside D],SUM(penalties) [Total Penalties]
from [UCL 2021-22]..Goals
GROUP BY club
order by [Total Goals] desc, [Total Goals From Outside D] desc,[Total Goals From Inside D] desc

--------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------

-- Now Let's
-- Nominate Player of the season

select *
 from [UCL 2021-22]..['Key Stats']
 ORDER BY 9 DESC ,6 DESC,7 DESC,8 DESC

 -- CLEARLY WE CAN THAT BENZEMA IS THE CLEAR WINNER OF IT 



