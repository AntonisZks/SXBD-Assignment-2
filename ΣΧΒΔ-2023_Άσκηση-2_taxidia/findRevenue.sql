-- Returns a table with all branches and their incomes
SELECT tab.travel_agency_branch_id, COUNT(r.Reservation_id)*tp.cost_per_person as income
FROM reservation r, travel_agency_branch tab, trip_package tp
WHERE r.travel_agency_branch_id =  tab.travel_agency_branch_id AND r.offer_trip_package_id = tp.trip_package_id
GROUP BY travel_agency_branch_id, tp.cost_per_person;

-- Returns a table with all braches with their number of reservations
SELECT tab.travel_agency_branch_id, COUNT(r.Reservation_id) as reservations
FROM reservation r, travel_agency_branch tab
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
GROUP BY tab.travel_agency_branch_id;

-- Returns a table with all branches and their number of employees and total salary
SELECT tab.travel_agency_branch_id, COUNT(e.employees_AM) AS num_of_employees, SUM(e.salary) AS total_salary
FROM employees e, travel_agency_branch tab
WHERE e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
GROUP BY tab.travel_agency_branch_id;

SELECT COUNT(*)
FROM travel_agency_branch;