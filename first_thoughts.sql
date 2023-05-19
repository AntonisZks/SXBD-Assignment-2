/* ΜΕΡΟΣ Α */

/*1. Βρείτε τα ονόματα των ξεναγών που έχουν χρησιμοποιηθεί από το πρακτορείο σε όλους τους προορισμούς της Γερμανίας. */
SELECT em.name
FROM employees em, travel_guide tg, guided_tour gt, trip_package tp, trip_package_has_destination tphd, destination d
WHERE em.employees_AM = tg.travel_guide_employee_AM 
      AND gt.travel_guide_employee_AM = tg.travel_guide_employee_AM
      AND gt.trip_package_id = tp.trip_package_id
      AND tp.trip_package_id = tphd.trip_package_trip_package_id
      AND tphd.destination_destination_id = d.destination_id
      AND d.country = "Germany"
GROUP BY em.name;

/* 2. Βρείτε τους κωδικούς των ξεναγών με περισσότερες από 3 ξεναγήσεις στο έτος 2019.*/
SELECT r.travel_guide_travel_guide_employee_AM
FROM reservation r
WHERE YEAR(r.reservation_date) = 2019
GROUP BY r.travel_guide_travel_guide_employee_AM
HAVING COUNT(DISTINCT r.offer_trip_package_id) > 3;


/* 3. Βρείτε τον αριθμό των υπαλλήλων που έχει κάθε υποκατάστημα του ταξιδιωτικού πρακτορείου.*/
SELECT e.substore_travel_agency_branch_id, COUNT(e.employee_id) AS num_employees
FROM employee e
GROUP BY e.substore_travel_agency_branch_id;


/* 4. Βρείτε τα ταξιδιωτικά πακέτα και τον αριθμό των κρατήσεων που έγιναν σε αυτά στο διάστημα '2021-01-01' έως '2021-12-31' με προορισμό το Παρίσι.*/
SELECT tp.trip_package_id, COUNT(r.reservation_id) AS num_reservations
FROM trip_package tp, reservation r
WHERE r.offer_trip_package_id = tp.trip_package_id
  AND r.reservation_date >= '2021-01-01'
  AND r.reservation_date <= '2021-12-31'
  AND tp.destination = 'Paris'
GROUP BY tp.trip_package_id;

/* 5. Βρείτε τους ξεναγούς που έχουν κάνει όλες τις ξεναγήσεις στην ίδια γλώσσα. */


/* 6. Ελέγξτε αν υπήρξε προσφορά μέσα στο έτος 2020 η οποία δεν χρησιμοποιήθηκε από κανέναν. Το ερώτημα θα πρέπει να επιστρέφει ως απάντηση μια σχέση με μια
πλειάδα και μια στήλη με τιμή “yes” ή “no”). Απαγορεύεται η χρήση Flow Control Operators (δηλαδή, if, case, κ.λπ.).*/
SELECT CASE WHEN EXISTS (
    SELECT *
    FROM trip_package
    WHERE trip_package_id NOT IN (
        SELECT DISTINCT offer_trip_package_id
        FROM reservation
        WHERE YEAR(reservation_date) = 2020
    )
) THEN 'yes' ELSE 'no' END;

/* 7. Βρείτε όλους τους άντρες ταξιδιώτες που έχουν ηλικία από 40 και πάνω κι έχουν κάνει κρατήσεις σε περισσότερα από 3 ταξιδιωτικά πακέτα.*/
SELECT t.traveler_id, t.name, t.surname
FROM traveler t
WHERE t.gender = 'Man'
  AND t.age >= 40
  AND (
    SELECT COUNT(DISTINCT r.offer_trip_package_id)
    FROM reservation r
    WHERE r.traveler_traveler_id = t.traveler_id
  ) > 3;
GROUP BY t.name,t.surname;

/* 8. Βρείτε τα ονόματα των ξεναγών που μιλάνε Αγγλικά και τον αριθμό των τουριστικών αξιοθέατων που έχει γίνει κάποια ξενάγηση από τον καθένα ξεναγό στην παραπάνω γλώσσα. */
SELECT tg.travel_guide_employee_AM, tg.name, tg.surname, COUNT(DISTINCT ta.tourist_attraction_id) AS num_attractions
FROM travel_guide tg, travel_guide_has_languages tghl, tourist_attraction ta
WHERE tg.travel_guide_employee_AM = tghl.travel_guide_employee_AM
  AND tghl.language_language_id = (
    SELECT language_id
    FROM language
    WHERE language_name = 'English'
  )
  AND EXISTS (
      SELECT *
      FROM trip_package_has_destination tphd, destination d
      WHERE tphd.destination_destination_id = d.destination_id
        AND EXISTS (
            SELECT *
            FROM trip_package tp
            WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
              AND EXISTS (
                  SELECT *
                  FROM reservation r
                  WHERE r.offer_trip_package_id = tp.trip_package_id
                    AND EXISTS (
                        SELECT *
                        FROM travel_guide tg2
                        WHERE tg2.travel_guide_employee_AM = tg.travel_guide_employee_AM
                          AND tg2.tourist_attraction_tourist_attraction_id = ta.tourist_attraction_id
                    )
              )
        )
  )
GROUP BY tg.travel_guide_employee_AM, tg.name, tg.surname;

/* 9. Βρείτε τη χώρα του "προορισμού" που υπάρχει σε περισσότερα ταξιδιωτικά πακέτα από οποιαδήποτε άλλη. */


/* 10.Βρείτε τους κωδικούς των ταξιδιωτικών πακέτων που περιλαμβάνουν όλους τους ταξιδιωτικούς προορισμούς που σχετίζονται με την Ιρλανδία. */
SELECT tp.trip_package_id 
FROM trip_package tp
WHERE NOT EXISTS (
    SELECT *
    FROM destination d
    WHERE d.destination_id IN (
        SELECT tphd.destination_destination_id
        FROM trip_package_has_destination tphd
        WHERE tphd.trip_package_trip_package_id = tp.trip_package_id
    )
      AND d.country <> 'Ireland'
);

