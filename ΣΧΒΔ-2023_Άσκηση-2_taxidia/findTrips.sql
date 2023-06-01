SELECT tp.cost_per_person, tp.max_num_participants, 
	   COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
	   e.name, e.surname, tp.trip_start, tp.trip_end
FROM reservation r, travel_agency_branch tab, trip_package tp, employees e, travel_guide tg, guided_tour gt
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id 
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tp.trip_package_id = gt.trip_package_id
  AND tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1 AND tp.trip_start >= '2022-01-01' AND tp.trip_start <= '2022-12-31'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, tg.travel_guide_employee_AM, tp.trip_start, tp.trip_end;