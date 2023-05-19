# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import lib.pymysql as db
import settings
import sys
import os
sys.path.append(os.path.join(os.path.split(
    os.path.abspath(__file__))[0], 'lib'))


def connection():
    ''' User this function to create your connections '''
    con = db.connect(
        settings.mysql_host,
        settings.mysql_user,
        settings.mysql_passwd,
        settings.mysql_schema)

    return con


def findTrips(x, a, b):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    q1 = f"""SELECT tp.cost_per_person, tp.max_num_participants, 
                 COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
                 CONCAT(e.name, ' ', e.surname) AS driver, tp.trip_start, tp.trip_end
             FROM reservation r 
                 JOIN travel_agency_branch tab ON r.travel_agency_branch_id = tab.travel_agency_branch_id
                 JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
                 JOIN employees e ON e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
                 JOIN drivers d ON d.driver_employee_AM = e.employees_AM
             WHERE tab.travel_agency_branch_id = {x} AND tp.trip_start BETWEEN '{a}' AND '{b}'
             GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, d.driver_employee_AM, tp.trip_start, tp.trip_end"""
    try:
        cursor.execute(q1)
        results = list(cursor.fetchall())
        results.insert(0, ("cost_per_person", "max_num_participants", "reservations", "empty_seats", "driver", "trip_start", "trip_end"))
        return results
    except:
        print("Error: unable to fetch data")

def findRevenue(x):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    q2 = f"""SELECT DISTINCT incomes_travel_agency_branch_id as travel_agency_branch_id, reservations AS total_num_reservations, SUM(income) AS total_income,
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
             ORDER BY total_income {x};"""
    
    try:
        cursor.execute(q2)
        results = list(cursor.fetchall())
        results.insert(0, ("travel_agency_branch_id", "total_num_reservations", "total_income", "total_num_employees", "total_salary"))
        return results
    except:
        print("Error: unable to fetch data")


def bestClient(x):

    # Create a new connection
    con = connection()
    # Create a cursor on the connection
    cur = con.cursor()

    return [("first_name", "last_name", "total_countries_visited", "total_cities_visited", "list_of_attractions"), ]


def giveAway(N):
    # Create a new connection
    con = connection()

    # Create a cursor on the connection
    cur = con.cursor()

    return [("string"), ]
