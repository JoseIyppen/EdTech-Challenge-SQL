select *
from champions

--Here, as the challenge starts on a Monday, iso_week is used to ensure that a week starts on Monday.  


-- Average learning hours per week before and during the challenge
select weekno, avg(l_hrs) as Average_learning_hours
from (
select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
 l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id 
) as k
group by weekno
order by weekno

--Count of weekly active days per user
select weekno, user_id, count(distinct day) as no_of_days_active_per_week
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions) as t
group by weekno, user_id 
order by weekno


-- Average weekly activity from whole period
select  weekno, avg(no_of_days_active_per_week) as Average_active_days
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

--Total number of lesson completions per week across the whole period
select weekno, sum(completion) as total_completions
from (select *, completion= case when overall_completion_percentage='100' then 1 else 0 end
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions  ) as t  ) as d
group by weekno


--Retention analysis

--Daily Active Users
select day, count(distinct user_id)
from (
select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions ) as g
group by day
order by day

--Number of distinct user logins on a weekly basis
select weekno, count(distinct user_id) as user_login
from (select *, DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day 
from champions) as t
group by weekno 
order by weekno
--shows marginal increase with challenge. Since increase is marginal, we can infer that
--the challenge was not much attractive to those who were already inactive. But still, some 
--of the users got active with the challenge.  




--Rewards analysis

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


--Week wise number of users achieving the goal
select weekno, count( user_id) as Number_of_goal_achievers
from (
select *
from (
select user_id, weekno, sum(completion) as lessons_completed, sum(l_hrs) as hrs_of_learning
from  (select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, 
completion= case when overall_completion_percentage='100' then 1 else 0 end, l_hrs=cast(day_completion_percentage as float )*lesson_duration_in_mins /(100*60)
from champions as t1
inner join champions2 as t2
on t1.lesson_id=t2.lesson_id
where cast(activity_datetime as date) between '09-12-2022' and '11-06-2022') as t1
group by user_id, weekno) as t2
where lessons_completed>=5 and hrs_of_learning>=3) as t3
group by weekno

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

-- From the above result we can conclude that most of the users who initially accepted the challenge achived the target.
-- The challenge was able to retent those users.



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

--Since they are in tie for the above criteria, we consider their single day lesson completion ability
select user_id, count(day_completion_percentage) as [No of single day lesson completions]
from (
select DATEPART(iso_week, activity_datetime ) as weekno, cast(activity_datetime as date) as day , user_id, day_completion_percentage
from champions
where user_id in ('user_218','user_309' ) and day_completion_percentage='100' ) as t
group by user_id
--returns
--user_218	368
--user_309	272

--Since user_218 has more single day lesson completions, user_218 be given the second prize

