SELECT tp.cost_per_person, tp.max_num_participants, 
	   COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
	   CONCAT(e.name, ' ', e.surname) AS travel_guide, tp.trip_start, tp.trip_end
FROM reservation r, travel_agency_branch tab, trip_package tp, employees e, travel_guide tg
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id 
  AND r.offer_trip_package_id = tp.trip_package_id
  AND e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1 AND tp.trip_start >= '2019-06-01' AND tp.trip_start <= '2022-09-12'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, tg.travel_guide_employee_AM, tp.trip_start, tp.trip_end;