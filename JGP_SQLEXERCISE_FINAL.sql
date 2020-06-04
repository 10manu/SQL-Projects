/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

#Code
SELECT name
FROM Facilities
WHERE membercost != 0

#Answer
'''Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court''' 

/* Q2: How many facilities do not charge a fee to members? */

#Code
SELECT COUNT(name)
FROM Facilities
WHERE membercost = 0.0 

#Answer
'4'


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

#Code
SELECT facid, 
    name, 
    membercost, 
    monthlymaintenance
FROM Facilities
WHERE (membercost / monthlymaintenance) < 0.2
AND membercost != 0.0


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

#Code
SELECT *
FROM Facilities
WHERE facid IN ( 1, 5 )

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

#CODE
SELECT name,
    monthlymaintenance,
    CASE WHEN monthlymaintenance > 100 THEN 'expensive'
    ELSE 'cheap' END AS cheap_or_expensive
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

#Code
SELECT firstname,
    surname
FROM Members
WHERE joindate = (
        SELECT MAX(joindate)
        FROM Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

#Code
SELECT a.name,
    sub.name
FROM (SELECT DISTINCT a.memid AS ID,
      a.facid AS facility_ID,
    CONCAT(b.firstname,' ' ,b.surname) AS name
FROM Bookings AS a
JOIN Members AS b
ON a.memid = b.memid) sub
JOIN Facilities AS a
ON a.facid = sub.facility_ID
ORDER BY sub.name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

#Code
SELECT c.name AS facility_name,
    CONCAT(a.firstname, ' ', a.surname) AS member_name,
    c.membercost * b.slots AS total_cost
FROM Members AS a
JOIN Bookings AS b ON a.memid = b.memid
JOIN Facilities AS c ON b.facid = c.facid
WHERE b.starttime LIKE '2012-09-14%' AND c.membercost * b.slots > 30.0
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

#Code
SELECT a.name as facility_name,
    sub.membername,
    a.membercost*sub.slots as total_cost
FROM
(SELECT CONCAT(a.firstname, ' ', a.surname) AS membername,
     b.facid as facility_id,
     b.slots as slots
 FROM Members as a
JOIN Bookings as b on a.memid=b.memid
WHERE starttime LIKE '2012-09-14%') as sub
JOIN Facilities as a
ON a.facid = sub.facility_id
WHERE a.membercost*sub.slots > 30.0
ORDER BY total_cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

#Code
SELECT facilityname,
    SUM(revenue) as revenue
FROM (SELECT  a.name as facilityname,
        CASE WHEN sub.membername LIKE 'GUEST%' THEN sub.slots * a.guestcost
        ELSE sub.slots * a.membercost END AS revenue
FROM
(SELECT a.facid as facility_id,
    a.memid,
    CONCAT(b.firstname, ' ', b.surname) as membername,
    a.starttime as starttime,
    a.slots as slots
FROM Bookings as a
JOIN Members as b 
ON a.memid = b.memid) as sub
JOIN Facilities as a
ON a.facid = sub.facility_id) as x
GROUP BY facilityname
HAVING revenue > 1000.0
ORDER BY revenue DESC

