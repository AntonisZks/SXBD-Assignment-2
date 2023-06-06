/* ΜΕΡΟΣ Α */

/*1. Βρείτε τα ονόματα των ξεναγών που έχουν χρησιμοποιηθεί από το πρακτορείο σε όλους τους προορισμούς της Γερμανίας. */
SELECT DISTINCT e.name, e.surname
FROM travel_guide tg, employees e, guided_tour gt, tourist_attraction ta, destination d
WHERE tg.travel_guide_employee_AM = e.employees_AM
  AND tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND gt.tourist_attraction_id = ta.tourist_attraction_id
  AND ta.destination_destination_id = d.destination_id
  AND d.country = 'Germany'
ORDER BY e.name;

/* 2. Βρείτε τους κωδικούς των ξεναγών με περισσότερες από 3 ξεναγήσεις στο έτος 2019.*/
SELECT tg.travel_guide_employee_AM AS travel_guide_id, COUNT(gt.trip_package_id) AS number_of_guided_tours
FROM travel_guide tg, guided_tour gt, trip_package tp
WHERE tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND gt.trip_package_id = tp.trip_package_id
  AND tp.trip_start >= '2019-01-01' AND tp.trip_start <= '2019-12-31'
GROUP BY tg.travel_guide_employee_AM
HAVING number_of_guided_tours > 3;

/* 3. Βρείτε τον αριθμό των υπαλλήλων που έχει κάθε υποκατάστημα του ταξιδιωτικού πρακτορείου.*/
SELECT tab.travel_agency_branch_id, COUNT(e.employees_AM) AS number_of_employees
FROM employees e, travel_agency_branch tab
WHERE tab.travel_agency_branch_id = e.travel_agency_branch_travel_agency_branch_id
GROUP BY tab.travel_agency_branch_id;

/* 4. Βρείτε τα ταξιδιωτικά πακέτα και τον αριθμό των κρατήσεων που έγιναν σε αυτά στο διάστημα '2021-01-01' έως '2021-12-31' με προορισμό το Παρίσι.*/
SELECT tp.trip_package_id, COUNT(r.Reservation_id) AS reservations
FROM trip_package tp, reservation r, trip_package_has_destination tphd, destination d
WHERE r.offer_trip_package_id = tp.trip_package_id
  AND tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND tp.trip_start >= '2021-01-01' AND tp.trip_start <= '2021-12-31'
  AND d.name = 'Paris'
GROUP BY tp.trip_package_id
ORDER BY tp.trip_package_id;

/* 5. Βρείτε τους ξεναγούς που έχουν κάνει όλες τις ξεναγήσεις στην ίδια γλώσσα. */
SELECT e.name, e.surname
FROM travel_guide tg, guided_tour gt, employees e
WHERE tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND tg.travel_guide_employee_AM = e.employees_AM
GROUP BY tg.travel_guide_employee_AM
HAVING COUNT(DISTINCT gt.travel_guide_language_id) = 1;

/* 6. Ελέγξτε αν υπήρξε προσφορά μέσα στο έτος 2020 η οποία δεν χρησιμοποιήθηκε από κανέναν. Το ερώτημα θα πρέπει να επιστρέφει ως απάντηση μια σχέση με μια
πλειάδα και μια στήλη με τιμή “yes” ή “no”). Απαγορεύεται η χρήση Flow Control Operators (δηλαδή, if, case, κ.λπ.).*/
SELECT DISTINCT 'yes' AS answer
FROM reservation r, offer o
WHERE r.offer_id = o.offer_id
    AND r.date >= '2020-01-01' AND r.date <= '2020-12-31'
    AND EXISTS (
        SELECT o.offer_id
        FROM reservation r, offer o
        WHERE r.offer_id = o.offer_id
            AND r.date >= '2020-01-01' AND r.date <= '2020-12-31'
        GROUP BY o.offer_id
        HAVING COUNT(r.Reservation_id) = 0)
UNION
SELECT DISTINCT 'no' AS answer
FROM reservation r, offer o
WHERE r.offer_id = o.offer_id
    AND r.date >= '2020-01-01' AND r.date <= '2020-12-31'
    AND NOT EXISTS (
        SELECT o.offer_id
        FROM reservation r, offer o
        WHERE r.offer_id = o.offer_id
            AND r.date >= '2020-01-01' AND r.date <= '2020-12-31'
        GROUP BY o.offer_id
        HAVING COUNT(r.Reservation_id) = 0);

/* 7. Βρείτε όλους τους άντρες ταξιδιώτες που έχουν ηλικία από 40 και πάνω κι έχουν κάνει κρατήσεις σε περισσότερα από 3 ταξιδιωτικά πακέτα.*/
SELECT t.name, t.surname
FROM traveler t
WHERE t.gender = 'male'
  AND t.age >= 40
  AND (
    SELECT COUNT(DISTINCT r.offer_trip_package_id)
    FROM reservation r
    WHERE r.Customer_id = t.traveler_id
  ) > 3
GROUP BY t.traveler_id, t.name, t.surname;

/* 8. Βρείτε τα ονόματα των ξεναγών που μιλάνε Αγγλικά και τον αριθμό των τουριστικών αξιοθέατων που έχει γίνει κάποια ξενάγηση από τον καθένα ξεναγό στην παραπάνω γλώσσα. */
SELECT tg.travel_guide_employee_AM AS travel_guide_id, em.name, em.surname, COUNT(ta.tourist_attraction_id) as number_of_attractions
FROM employees em, travel_guide tg, travel_guide_has_languages tghl, tourist_attraction ta, guided_tour gt
WHERE tg.travel_guide_employee_AM = tghl.travel_guide_employee_AM
  AND    em.employees_AM= tg.travel_guide_employee_AM
  AND tghl.languages_id = (
    SELECT languages_id
    FROM languages l
    WHERE l.name = 'English'
  )
  AND tg.travel_guide_employee_AM=gt.travel_guide_employee_AM
  AND gt.travel_guide_language_id=tghl.languages_id
  AND ta.tourist_attraction_id=gt.tourist_attraction_id
  GROUP BY tg.travel_guide_employee_AM, em.name, em.surname 
  ORDER BY tg.travel_guide_employee_AM ;

/* 9. Βρείτε τη χώρα του "προορισμού" που υπάρχει σε περισσότερα ταξιδιωτικά πακέτα από οποιαδήποτε άλλη. */
SELECT d.country
FROM destination d, trip_package_has_destination tphd, trip_package tp
WHERE d.destination_id = tphd.destination_destination_id
  AND tphd.trip_package_trip_package_id = tp.trip_package_id
GROUP BY d.destination_id
HAVING COUNT(tp.trip_package_id) >= ALL(
	SELECT COUNT(tp2.trip_package_id)
	FROM destination d2, trip_package_has_destination tphd2,trip_package tp2 
	WHERE d2.destination_id <> d.destination_id
	  AND d2.destination_id = tphd2.destination_destination_id
	  AND tphd2.trip_package_trip_package_id = tp2.trip_package_id
	GROUP BY d2.destination_id);

/* 10.Βρείτε τους κωδικούς των ταξιδιωτικών πακέτων που περιλαμβάνουν όλους τους ταξιδιωτικούς προορισμούς που σχετίζονται με την Ιρλανδία. */
SELECT DISTINCT tp.trip_package_id 
FROM trip_package tp, trip_package_has_destination tphd, destination d
WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND d.country = 'Ireland'
  GROUP BY tp.trip_package_id
  HAVING COUNT(tphd.destination_destination_id) = (
		SELECT COUNT(d.destination_id) as dnum
		FROM destination  d
		WHERE d.country='Ireland'
  );
  
