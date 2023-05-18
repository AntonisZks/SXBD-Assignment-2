-- Query 2: findRevenue | Order: DESC
--
--
--
-- Construction with JOIN
--
--
--
SELECT DISTINCT incomes_travel_agency_branch_id as travel_agency_branch_id, reservations AS total_num_reservations, SUM(income) AS total_income,
	   num_of_employees, total_salary
FROM (
	  -- Returns a table with all branches and their incomes
	  SELECT tab.travel_agency_branch_id AS incomes_travel_agency_branch_id, COUNT(r.Reservation_id)*tp.cost_per_person as income
	  FROM reservation r
	     JOIN travel_agency_branch tab ON r.travel_agency_branch_id =  tab.travel_agency_branch_id
		 JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
	  GROUP BY incomes_travel_agency_branch_id, tp.cost_per_person
	 ) travel_agency_branch_incomes JOIN
     (
      -- Returns a table all braches with their number of reservations
      SELECT tab.travel_agency_branch_id AS reservations_travel_agency_branch_id, COUNT(r.Reservation_id) as reservations
	  FROM reservation r 
		 JOIN travel_agency_branch tab ON r.travel_agency_branch_id = tab.travel_agency_branch_id
	  GROUP BY reservations_travel_agency_branch_id
     ) travel_agency_branch_reservations ON travel_agency_branch_incomes.incomes_travel_agency_branch_id = travel_agency_branch_reservations.reservations_travel_agency_branch_id JOIN
     (
	  -- Returns a table with all branches and their number of employees and total salary
      SELECT tab.travel_agency_branch_id AS employees_travel_agency_brach_id, COUNT(e.employees_AM) AS num_of_employees, SUM(e.salary) AS total_salary
	  FROM employees e 
	     JOIN travel_agency_branch tab ON e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
	  GROUP BY employees_travel_agency_brach_id
	 ) travel_agency_branch_employees ON reservations_travel_agency_branch_id = travel_agency_branch_employees.employees_travel_agency_brach_id
GROUP BY incomes_travel_agency_branch_id
ORDER BY total_income DESC;

--
--
--
-- Construction with WHERE
--
--
--
SELECT DISTINCT incomes_travel_agency_branch_id as travel_agency_branch_id, reservations AS total_num_reservations, SUM(income) AS total_income,
	   num_of_employees, total_salary
FROM (
	  -- Returns a table with all branches and their incomes
	  SELECT tab.travel_agency_branch_id AS incomes_travel_agency_branch_id, COUNT(r.Reservation_id)*tp.cost_per_person as income
	  FROM reservation r, travel_agency_branch tab, trip_package tp
	  WHERE r.travel_agency_branch_id =  tab.travel_agency_branch_id AND r.offer_trip_package_id = tp.trip_package_id
	  GROUP BY incomes_travel_agency_branch_id, tp.cost_per_person
	 ) travel_agency_branch_incomes,
     (
      -- Returns a table all braches with their number of reservations
      SELECT tab.travel_agency_branch_id AS reservations_travel_agency_branch_id, COUNT(r.Reservation_id) as reservations
	  FROM reservation r, travel_agency_branch tab
	  WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
	  GROUP BY reservations_travel_agency_branch_id
     ) travel_agency_branch_reservations,
     (
	  -- Returns a table with all branches and their number of employees and total salary
      SELECT tab.travel_agency_branch_id AS employees_travel_agency_brach_id, COUNT(e.employees_AM) AS num_of_employees, SUM(e.salary) AS total_salary
	  FROM employees e, travel_agency_branch tab
	  WHERE e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
	  GROUP BY employees_travel_agency_brach_id
	 ) travel_agency_branch_employees
WHERE travel_agency_branch_incomes.incomes_travel_agency_branch_id = travel_agency_branch_reservations.reservations_travel_agency_branch_id
  AND reservations_travel_agency_branch_id = travel_agency_branch_employees.employees_travel_agency_brach_id
GROUP BY incomes_travel_agency_branch_id
ORDER BY total_income DESC;