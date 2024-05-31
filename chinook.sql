/*
Question #1:
Write a solution to find the employee_id of managers with at least 2 direct reports.


Expected column names: employee_id

*/

-- q1 solution:

select
	employee_id
from employee
where title Like '%Manager' and employee_id in (select
                                 reports_to
                                 from employee
                                 group by reports_to
                                having count(*)>=2)
order by employee_id asc;




/*

Question #2: 
Calculate total revenue for MPEG-4 video files purchased in 2024.

Expected column names: total_revenue

*/

-- q2 solution:

select
	sum(invoice_line.unit_price*invoice_line.quantity) as total_revenue
from invoice_line
	left join track on track.track_id=invoice_line.track_id
	left join media_type on media_type.media_type_id=track.media_type_id
	left join invoice on invoice.invoice_id=invoice_line.invoice_id
where media_type.media_type_id=3 and invoice.invoice_date::date between '2024-01-01' and '2024-12-31';


/*
Question #3: 
For composers appearing in classical playlists, count the number of distinct playlists they appear on and 
create a comma separated list of the corresponding (distinct) playlist names.

Expected column names: composer, distinct_playlists, list_of_playlists

*/

-- q3 solution:

select
  	composer,
  	count (distinct playlist_track.playlist_id) as distinct_playlists,
  	string_agg (playlist.name, ',') as list_of_playlists
from track
	left join playlist_track on playlist_track.track_id= track.track_id
	left join playlist on playlist.playlist_id=playlist_track.playlist_id
where playlist.name like 'Classical%' and composer is not null
group by 1;



/*
Question #4: 
Find customers whose yearly total spending is strictly increasing*.


*read the hints!


Expected column names: customer_id
*/

-- q4 solution:

with temp_table as(

select
	customer_id,
	extract (year from invoice_date::date) as year_of_invoice,
	sum(total) as total_revenue,
	lag(sum(total)) over (partition by customer_id order by extract (year from 		invoice_date::date)) as previous_year_revenue
from invoice
WHERE EXTRACT(YEAR FROM invoice_date::date) !=2025
group by 1,2
order by 1,2)

select
	customer_id
from temp_table
group by customer_id
having bool_and(total_revenue > previous_year_revenue);

