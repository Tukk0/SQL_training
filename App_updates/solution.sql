WITH launches as (
	SELECT user_id, event_name, time, rank() OVER (PARTITION BY user_id ORDER BY time) as launch_number
	FROM table1
	WHERE event_name = 'launch'
), first_launches as (
	SELECT user_id, time, launch_number
	FROM launches
	WHERE launch_number = 1
), updating_users as (
	SELECT t1.user_id, t1.time, t1.event_name
	FROM table1 t1
		JOIN first_launches fl ON t1.user_id = fl.user_id
	WHERE event_name = 'update' and (t1.time - fl.time) < 15
), cohorts as (
	SELECT t1.user_id, event_name, product_id, t1.time, ((t1.time - '2023-03-01') / 7 + 1) as week
	FROM table1 t1
		JOIN first_launches fl ON t1.user_id = fl.user_id
	WHERE t1.user_id = fl.user_id AND t1.time = fl.time
), updating_users_per_week as (
	SELECT c.week as week, count(*) OVER (PARTITION BY c.week) as users
	FROM cohorts c
		JOIN updating_users uu ON c.user_id = uu.user_id
), users as (
	SELECT week, count(*) OVER (PARTITION BY week) as users
	FROM cohorts
)
SELECT distinct u.week, u.users, (CAST(uupw.users as FLOAT) / CAST(u.users AS FLOAT)) as CR
FROM users u
	LEFT JOIN updating_users_per_week uupw ON u.week = uupw.week
