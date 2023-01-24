# -Nextwave-sql


Context

Assume you are a data analyst in an EdTech company. The company’s customer success team works with
an objective to help customers get maximum value from their product and help them reach their goals.
As part of the customer success team's efforts to achieve this objective, they organized “Champions
Challenge” and offered exciting rewards to improve the engagement of users and maintain their
willingness to consistently learn.
You are provided with before and during the challenge learning data of users. Analyze the data to
understand the efficacy of the challenge and provide the team with supportive analytics to make data
informed decisions and plan action items.


Expected Outcome

1. Your analysis should help your customer success team understand the following.
○ If the challenge has improved the user engagement
i. Avg. learning hrs per week before and during the challenge
ii. Active days per week before and during the challenge
iii. No. of lessons completed per week before and during the challenge
○ How is the retention during the challenge
i. DAU, WAU
ii. Batch wise retention analysis
iii. Week wise no. of users achieving the goal
○ Total rewards and winners details for helping the team present the rewards
i. Rewards(goodies) wise counts
ii. Top 3 Winners
Additionally, present relevant analyses and insights to the team that help them make better
decisions about the challenge.
2. In case you identify any outliers in the data set, make a note of them and exclude them from your
analysis.
3. Build the best suitable dashboard presenting your insights.
Challenge Details
The Challenge is conducted for a duration of 8 weeks, from 12 Sept, 2022 to 6 Nov, 2022 for the users
enrolled in various batches.
Target: Complete at least 5 weekly goals out of the 8 weeks and a total learning duration of 20+ hrs
during the challenge
Weekly Goal: To complete at least 5 lessons and 3 hrs of learning in the calendar week


Rewards:

1. The top 3 users who achieved the target and have maximum no. of learning hours in the
challenge will be awarded with special gifts
★ 1st Position : Laptop
★ 2nd Position : Tablet
★ 3rd Position: Smart Watch
Note: In case of a tie between users in the top 3, define a suitable ranking criteria and pick the
winners
2. To encourage consistent learning, the users will be sent goodies based on their total weekly goal
achievements too. The rewards that will be awarded are in the table challenge_rewards



Overview of the Dataset

Four tables are included in the dataset containing the basic information about the users, their daily
completion percentages of lessons, the lesson details, and list of rewards.
1. users_basic_details:
● user_id: unique id of the user [string]
● batch_week: week of the batch, for which the user is enrolled [date]
● challenge_start_date: date at which the challenge started [date]
2. day_wise_user_learning_activity:
● datetime: date and time of learning of the user [datetime]
● user_id: unique id of the user [string]
● lesson_id: unique id of the lesson [string]
● day_completion_percentage: percent of the lesson completed by the user on a particular day
(out of 100%) [float]
○ The completion percentage is calculated by the formula = learned duration of a lesson
on a day/total duration of the lesson * 100
● overall_completion_percentage: overall completion percentage of the lesson till that datetime
by the user (out of 100%) [float]
Example: If a user, who started a lesson on Jan 1, ’22 completes the lesson by learning it
in parts (20%, 43%, 37% each day) on 3 different days (Jan 1, Jan 3, Jan 4), then
○ Jan 1, ‘22 ; day_completion_percentage - 20%, overall_completion_percentage - 20%
○ Jan 3, ‘22 ; day_completion_percentage - 43%, overall_completion_percentage - 63%
○ Jan 4, ‘22 ;day_completion_percentage - 37%, overall_completion_percentage - 100%
Note: The lesson will be considered as completed on the day when the overall completion
percentage is 100, i.e., on Jan 4, ‘22
3. lesson_details:
● lesson_id: unique id of the lessons in the learning platform [string]
● lesson_duration_in_mins: the duration of each lesson in minutes [integer]
4. challenge_rewards:
● total_weekly_goals_achieved: no. of weekly goals achieved [integer]
● reward: reward to be awarded based on the weekly goals achieved[string]
