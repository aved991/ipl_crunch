select *
from ipl_crunch

--1. Do teams that win the toss actually win more matches?

with WinToss_win as (
select distinct match_id, toss_winner, winner
from ipl_crunch)

select toss_winner as team_name, count(*) as toss_wins,
cast(ROUND((sum(case when toss_winner=winner then 1 else 0 end)*100.0)/COUNT(*),2)
as decimal(4,2)) 
as toss_win_match_win_percentage

from WinToss_win
group by toss_winner
order by toss_win_match_win_percentage

--2. Which phase — powerplay, middle overs, or death overs — is most linked to winning?

with PhaseRuns as 
(
select match_id, batting_team, 
case
	when [over] between 0 and 6 then 'PowerPlay'
	when [over] between 7 and 15 then 'Middle overs'
	else 'Death overs'
	end as phase,
sum(runs_total) as phase_runs,
max(winner) as winner

from ipl_crunch
group by match_id, batting_team,

case
	when [over] between 0 and 6 then 'PowerPlay'
	when [over] between 7 and 15 then 'Middle overs'
	else 'Death overs'
	end)

select phase,
avg(case
	when batting_team=winner
	then phase_runs
	end)
	as avg_runs_winning_teams,
avg(case
	when batting_team<> winner
	then phase_runs
	end)
	as avg_runs_losing_teams

from PhaseRuns
group by phase
order by CASE
        WHEN phase = 'PowerPlay' THEN 1
        WHEN phase = 'Middle overs' THEN 2
        WHEN phase = 'Death overs' THEN 3
    END;

--3. Who are the top 5 batters and top 5 bowlers across 5 seasons?



select batter, sum(runs_total) as runs
from ipl_crunch

group by batter 
order by runs desc

select bowler, 
	count(case
			when wicket_kind not in('run out', 'retired hurt')
			then 1 end) as total_wickets
from ipl_crunch

group by bowler
order by total_wickets Desc

--Distinct seasons within the data
select distinct season
from ipl_crunch
order by season

--Season 2010 is missing from the dataset
update ipl_crunch
set season = 2010
where season IS NULL;