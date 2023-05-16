SELECT *
FROM destination;

# Question 1
SELECT em.name
FROM employees em, travel_guide tg, guided_tour gt, trip_package tp, trip_package_has_destination tphd, destination d
WHERE em.employees_AM = tg.travel_guide_employee_AM 
	  AND gt.travel_guide_employee_AM = tg.travel_guide_employee_AM
      AND gt.trip_package_id = tp.trip_package_id
      AND tp.trip_package_id = tphd.trip_package_trip_package_id
      AND tphd.destination_destination_id = d.destination_id
      AND d.country = "Germany"
GROUP BY em.name;