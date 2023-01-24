select *
from champions

--Here, as the challenge starts on a Monday, iso_week is used to ensure that a week starts on Monday.  

--Number of distinct user logins on a weekly basis
select weekno, count(distinct user_id)
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions) as t
group by weekno 
order by weekno
--(no considerble increase with challenge?)



--Count of weekly active days per user
select weekno, user_id, count(distinct day) as no_of_days_active_per_week
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions) as t
group by weekno, user_id 
order by weekno




-- avg active days per week 
-- Average weekly activity from 17-July to 06-Nov 
select  weekno, avg(no_of_days_active_per_week)
from (select weekno, user_id, cast(count(distinct day) as float ) as no_of_days_active_per_week
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions) as t
group by weekno, user_id  ) as p
group by weekno
order by weekno




--Average of lesson completions per week before the start of the challenge
select  AVG(total_completions) 
from ( select weekno, sum(completion) as total_completions
from (select *, completion= case when overall_completion_percentage='100' then 1 else 0 end
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions  ) as t where day<'2022-09-12'   ) as d
group by weekno ) as f
--returns 2466



--Average number of lesson completions per week during the challenge
select  AVG(total_completions) 
from ( select weekno, sum(completion) as total_completions
from (select *, completion= case when overall_completion_percentage='100' then 1 else 0 end
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions  ) as t where day>='2022-09-12'   ) as d
group by weekno ) as f
--returns 3162




--The following gives the list of users who have achieved a weekly goal along with the respective week  
with goal_cte as (
select user_id, weekno, sum(completion) as lessons_completed, sum(l_hrs) as hrs_of_learning
from    (   select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
completion= case when overall_completion_percentage='100' then 1 else 0 end, l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id 
where cast(activity_datetime as date) between '09-12-2022' and '11-06-2022') as t
group by user_id, weekno 
)
select *
from goal_cte
where lessons_completed>=5 and hrs_of_learning>=3
order by weekno, lessons_completed desc, hrs_of_learning desc



--Rewards for weekly goals

select *
from rewards

--The following query lists the user_id's along with the reward for which they are eligible
select user_id, goal_cnt_for_reward, reward
from (
select user_id, count(weekno) as no_of_weekly_goals, goal_cnt_for_reward=case when count(weekno)>5 then 5 else count(weekno) end
from (
select *
from (
select user_id, weekno, sum(completion) as lessons_completed, sum(l_hrs) as hrs_of_learning
from    (   select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
completion= case when overall_completion_percentage='100' then 1 else 0 end, l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id 
where cast(activity_datetime as date) between '09-12-2022' and '11-06-2022') as t
group by user_id, weekno 
) as g
where lessons_completed>=5 and hrs_of_learning>=3
) as goal
group by user_id ) as p
inner join rewards as r
on goal_cnt_for_reward=total_weekly_goals_achieved

--The below query returns the total number of rewards to be distributed

select  reward, count(user_id)
from (
select user_id, count(weekno) as no_of_weekly_goals, goal_cnt_for_reward=case when count(weekno)>5 then 5 else count(weekno) end
from (
select *
from (
select user_id, weekno, sum(completion) as lessons_completed, sum(l_hrs) as hrs_of_learning
from    (   select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
completion= case when overall_completion_percentage='100' then 1 else 0 end, l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id 
where cast(activity_datetime as date) between '09-12-2022' and '11-06-2022') as t
group by user_id, weekno 
) as g
where lessons_completed>=5 and hrs_of_learning>=3
) as goal
group by user_id ) as p
inner join rewards as r
on goal_cnt_for_reward=total_weekly_goals_achieved
group by reward

--Backpack		42
--Head Phones	208
--Sweatshirt	26
--T-shirt		16
--Water Bottle	38



--Target achievers


--The following query returns the Top 3 users who achieved the target and have maximum number of learning hours.

select top 3 user_id, count(weekno) as no_of_week_goals, sum(hrs_of_learning) as total_hrs
from (
select *
from (
select user_id, weekno, sum(completion) as lessons_completed, sum(l_hrs) as hrs_of_learning
from    (   select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
completion= case when overall_completion_percentage='100' then 1 else 0 end, l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id 
where cast(activity_datetime as date) between '09-12-2022' and '11-06-2022') as t
group by user_id, weekno 
) as g
where lessons_completed>=5 and hrs_of_learning>=3
) as goal
group by user_id 
having count(weekno)>=5 and sum(hrs_of_learning)>20
order by total_hrs desc

--From the above query, we get that the following users are the top 3: 
--user_141   8  164.802258333333
--user_309   8  157.8
--user_218   8  157.8


--It can be observed that user_218 and user_309 are equally performing with regards to number of weekly goals and total learning hours.
--So to decide who should be given second prize, we need further analysis.


-- The following query will determine the total number of lessons completed by each of the users during the challenge period:
select user_id, count(distinct lesson_id)
from champions
where user_id in ('user_218 ','user_309 ') and overall_completion_percentage='100' and cast(activity_datetime as date) between '09-12-2022' and '11-06-2022'
group by user_id

--user_218  199
--user_309  199

--Since they are in tie for the above criteria, we consider

--Thus, user_218 be given the third prize




