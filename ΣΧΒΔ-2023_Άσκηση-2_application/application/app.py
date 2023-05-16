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

    q1 = f"""SELECT tp.cost_per_person, tp.max_num_participants, COUNT(r.Reservation_id), (tp.max_num_participants - COUNT(r.Reservation_id)), tp.trip_start, tp.trip_end
             FROM trip_package tp, reservation r
             WHERE tp.trip_package_id = {x} AND tp.trip_start >= '{a}' AND tp.trip_end <= '{b}' AND tp.trip_package_id = r.offer_trip_package_id
             GROUP BY tp.cost_per_person, tp.max_num_participants, tp.trip_start, tp.trip_end;"""
    try:
        cursor.execute(q1)
        results = list(cursor.fetchall())
        results.insert(0, ("cost_per_person", "max_num_participants", "reservations", "empty_seats", "trip_start", "trip_end"))
        return results
    except:
        print("Error: unable to fetch data")

def findRevenue(x):

   # Create a new connection
    con = connection()

    # Create a cursor on the connection
    cur = con.cursor()

    return [("travel_agency_branch_id", "total_num_reservations", "total_income", "total_num_employees", "total_salary"), ]


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
