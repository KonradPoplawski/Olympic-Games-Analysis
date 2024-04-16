-- Olympic Games Analysis


-- 1. How many olympic games have been held?


select count(distinct games) as total_olympic_games
from athlete_events ae; 


-- 2. List down all olympic games held.

select distinct games
from athlete_events ae 
order by 1;


-- 3. Mention the total number of nations which participated in each olympic games.


with all_countries as
	(
	select 
		ae.games
		,nr.region
	from athlete_events ae 
	join noc_regions nr on nr.noc = ae.noc
	)
select 
	games
	,count(distinct region) as total_countries
from all_countries
group by 1
order by 1;


-- 4. Which year saw the highest and the lowest no of countries participatin in olympics?


with all_countries as
	(
	select 
		ae.games
		,nr.region
	from athlete_events ae 
	join noc_regions nr on nr.noc = ae.noc
	),
lowest as 
	(
	select 
		games
		,count(distinct region) as lowest_countries
	from all_countries
	group by 1
	order by 2 asc
	limit 1
	),
highest as 
	(
	select 
		games
		,count(distinct region) as highest_countries
	from all_countries
	group by 1
	order by 2 desc
	limit 1
	)
select games, highest_countries as no_of_countries from highest
union
select * from lowest
order by 2 asc;


-- 5. Which nation has participated in all of the olympic games?


with total_games as
	(
	select count(distinct games) as total_game
	from athlete_events
	),
countries as
	(
	select 
		ae.games
		,nr.region as country
	from athlete_events ae
	join noc_regions nr on ae.noc = nr.noc
	),
cuntries_participated as 
	(
	select
		country
		,count(distinct games) as total_participated_games
	from countries
	group by 1
	order by 2 desc
	)
select cp.*
from cuntries_participated cp
join total_games tg on cp.total_participated_games = tg.total_game;
	

-- 6. Idenify the sports which were played in all summer olympics.


with t1 as
	(
	select count(distinct games) as total_summer_games
	from athlete_events
	where season = 'Summer'
	order by 1 asc
	),
t2 as 
	(
	select
		distinct sport
		,games
	from athlete_events 
	where season = 'Summer'
	order by 2
	),
t3 as 
	(
	select 
		sport
		,count(games) as no_of_games
	from t2
	group by 1
	order by 2 desc
	)
select * 
from t3
join t1 on t1.total_summer_games = t3.no_of_games;


-- 7. Which sports were played only once in the olympics?

with t1 as
	(
	select
			distinct sport
			,games
		from athlete_events 
		where season = 'Summer'
		order by 2
	)
select 
	sport
	,count(games) as no_of_olympic_games
from t1
group by 1
having count(games) = 1;


-- 8. Total number of sports played in each olympic games


with t1 as
	(
	select
		distinct games
		,sport
	from athlete_events 
	order by 2
	),
t2 as 
	(
	select 
		games
		,count(sport) as no_of_sports_played
	from t1
	group by 1
	order by 2 desc
	)
select * from t2
order by 1;

-- 9. The oldest athlets to win a gold medal.

select *
	,rank() over (order by age desc) as ranking
from athlete_events ae 
where age <> 'NA' and medal = 'Gold'
limit 10;


-- 10. Ratio of male and female athletes participated in olympic games.


select 
	sex
	,round(count(*) / (select count(*) from athlete_events) * 100, 2) as percentage_ratio
from athlete_events
group by 1;
	

-- 11. Top 5 athlets who have won the most gold medals.


with t1 as
	(
	select 
		name
		,count(medal) as total_gold_medals
	from athlete_events 
	where medal = 'Gold'
	group by 1
	order by 2 desc
	),
t2 as 
	(
	select 
		name
		,total_gold_medals
		,dense_rank () over (order by total_gold_medals desc) as ranking
	from t1
	)
select * from t2
where ranking < 6;



-- 12. List down total gold, silver and broze medals won by each country.

with gold as
	(
	select 
		nr.region as country
		-- ,ae.medal
		,count(ae.medal) as total_gold
	from athlete_events ae
	join noc_regions nr on ae.noc = nr.noc
	where medal <> 'NA' and ae.medal = 'Gold'
	group by 1
	order by 2 desc
	),
silver as
	(
	select 
		nr.region as country
		-- ,ae.medal
		,count(ae.medal) as total_silver
	from athlete_events ae
	join noc_regions nr on ae.noc = nr.noc
	where medal <> 'NA' and ae.medal = 'Silver'
	group by 1
	order by 2 desc
	),
bronze as
	(
	select 
		nr.region as country
		-- ,ae.medal
		,count(ae.medal) as total_bronze
	from athlete_events ae
	join noc_regions nr on ae.noc = nr.noc
	where medal <> 'NA' and ae.medal = 'Bronze'
	group by 1
	order by 2 desc
	)
select 
	g.country
	,g.total_gold
	,s.total_silver
	,b.total_bronze
from gold g
left join silver s on g.country = s.country
left join bronze b on g.country = b.country;


-- 13. In which sport Poland has won the highest medals?

with t1 as
	(
	select 	
		sport
		,count(*) as total_medals
	from athlete_events
	where medal <> 'NA' and team = 'Poland'
	group by 1
	order by 2
	),
t2 as 
	(
	select *
	,rank () over (order by total_medals desc) as ranking
	from t1
	)
select * from t2;

	



















	
	
	
	
	
	
	
	

	
	