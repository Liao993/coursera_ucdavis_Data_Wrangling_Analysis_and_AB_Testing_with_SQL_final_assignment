-- Ql : Does this table have everything you need to compute metrics like 30-day view-binary?

select *
from dsv1069.final_assignments_qa


--Answer : No











-- Q2 : Write a query and table creation statement to make final_assignments_qa look like the final_assignments table. 
--If you discovered something missing in part 1, you may fill in the value with a place holder of the appropriate data type. 



SELECT *

FROM

    (

    SELECT 

      item_id                                                                   AS item_id, 

      test_a                                                                    AS test_assignment, 

      (CASE WHEN test_a IS NOT NULL THEN 'test_a' ELSE NULL END )               AS test_number,

      (CASE WHEN test_a IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END )  AS date_start

    FROM 

      dsv1069.final_assignments_qa

  UNION

    SELECT 

      item_id, 

      test_b                                                                   AS test_assignment, 

      (CASE WHEN test_b IS NOT NULL THEN 'test_b' ELSE NULL END )              AS test_number,

      (CASE WHEN test_b IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END ) AS date_start

    FROM 

      dsv1069.final_assignments_qa

  UNION

    SELECT 

      item_id, 

      test_c                                                                   AS test_assignment, 

      (CASE WHEN test_c IS NOT NULL THEN 'test_c' ELSE NULL END )              AS test_number,

      (CASE WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END ) AS date_start

    FROM 

      dsv1069.final_assignments_qa

  UNION

    SELECT 

      item_id, 

      test_d                                                                   AS test_assignment, 

      (CASE WHEN test_d IS NOT NULL THEN 'test_d' ELSE NULL END )              AS test_number,

      (CASE WHEN test_d IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END ) AS date_start

    FROM 

      dsv1069.final_assignments_qa

  UNION

    SELECT 

      item_id, 

      test_e                                                                   AS test_assignment, 

      (CASE WHEN test_e IS NOT NULL THEN 'test_e' ELSE NULL END )              AS test_number,

      (CASE WHEN test_e IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END ) AS date_start

    FROM 

      dsv1069.final_assignments_qa

  UNION

    SELECT 

      item_id, 

      test_f                                                                   AS test_assignment, 

      (CASE WHEN test_f IS NOT NULL THEN 'test_f' ELSE NULL END )              AS test_number,

      (CASE WHEN test_f IS NOT NULL THEN '2013-01-05 00:00:00' ELSE NULL END ) AS date_start

    FROM 

      dsv1069.final_assignments_qa) remodeled_table









-- Q3 : Use the final_assignments table to calculate the order binary for the 30 day window after the test assignment for item_test_2
--(You may include the day the test started)

SELECT the_order_binary.test_assignment,
       COUNT(DISTINCT the_order_binary.item_id) AS num_orders,
       SUM(the_order_binary.orders_bin_30d) AS sum_orders_bin_30d
FROM
  (SELECT assignments.item_id,
          assignments.test_assignment,
          MAX(CASE
                  WHEN (DATE(orders.created_at)-DATE(assignments.test_start_date)) BETWEEN 1 AND 30 THEN 1
                  ELSE 0
              END) AS orders_bin_30d
   FROM dsv1069.final_assignments AS assignments
   LEFT JOIN dsv1069.orders AS orders
     ON assignments.item_id=orders.item_id
   WHERE assignments.test_number='item_test_2'
   GROUP BY assignments.item_id,
            assignments.test_assignment) AS the_order_binary
GROUP BY the_order_binary.test_assignment






-- Q4 : Use the final_assignments table to calculate the view binary, 
-- and average views for the 30 day window after the test assignment for item_test_2. (You may include the day the test started)

SELECT test_assignment,
       SUM(view_binary) AS views_binary_30,
       count(distinct item_id) AS items,
	   CAST(100*SUM(view_binary)/COUNT(item_id) AS FLOAT) AS viewed_percent,
      SUM(events)/COUNT(item_id) AS average_views_per_item
FROM (
SELECT test_events.item_id,
       test_events.test_assignment,
       test_events.test_number,
       test_events.test_date,
       count(event_id) as events,
       MAX(CASE
               WHEN (event_time > test_events.test_date
                     AND DATE_PART('day', event_time-test_date) <= 30) THEN 1
               ELSE 0
           END) AS view_binary
FROM
  (SELECT assignment.item_id AS item_id,
          test_assignment,
          test_number,
          test_start_date AS test_date,
          event_time,
          event_id
   FROM dsv1069.final_assignments assignment
   LEFT JOIN
       (SELECT event_time, 
              event_id,
               CASE
                   WHEN parameter_name = 'item_id' then cast (parameter_value AS float)
                   ELSE null
               END AS item_id
      FROM dsv1069.events
      WHERE event_name = 'view_item' ) AS views
     ON assignment.item_id =views.item_id
     WHERE test_number = 'item_test_2' 
     ) AS test_events
   GROUP BY test_events.item_id,
         test_events.test_assignment,
         test_events.test_number,
       test_events.test_date
         ) AS views_binary
GROUP BY test_assignment,
  test_date


-- Q5: Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics 
--( 30 day order binary and 30 day view binary) using a interval 95% confidence. 


-- order binary : -15% – 11% (-2.2%) pvalue = 0.74

-- view binary : -1.4% – 6.5% (2.6%) pvalue = 0.2

-- Therefore, there is no significant difference for item_test_2 in view binary and order binary
