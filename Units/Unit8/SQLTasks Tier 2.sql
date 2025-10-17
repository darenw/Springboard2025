/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 

Note:  login to sql.springboard.com fails.  Using DB Browser for SQLite on local machine.

BASH command running on Arch Linux:   darenw>  sqlitebrowser  sqlite_db_pythonsqlite.db



/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name FROM Facilities WHERE membercost=0;

Badminton Court
Table Tennis
Snooker Table
Pool Table



/* Q2: How many facilities do not charge a fee to members? */

4



/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT name, facid, membercost, monthlymaintenance FROM Facilities WHERE membercost > 0 AND membercost < 0.2 * monthlymaintenance;


Tennis Court 1        0       5         200
Tennis Court 2        1       5         200
Massage Room 1    4	       9.9    3000
Massage Room 2    5	       9.9    3000
Squash Court          6       3.5        80



/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities WHERE facid IN (1,5)


1   Tennis Court 2     5      25   8000	200
5   Massage Room 2     9.9    80   4000	3000



/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
	name, 
	monthlymaintenance, 
	CASE 
		WHEN monthlymaintenance>100 THEN 'expensive' 
		ELSE 'cheap'
	END  AS 'costliness'
FROM Facilities
ORDER BY costliness, name;



name                    monthlymaintenance     costliness
Badminton Court               50                  cheap
Pool Table                    15                  cheap
Snooker Table                 15                  cheap
Squash Court                  80                  cheap
Table Tennis                  10                  cheap
Massage Room 1              3000                expensive
Massage Room 2              3000                expensive
Tennis Court 1               200                expensive
Tennis Court 2               200                expensive



/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT memid, firstname, surname, joindate 
FROM Members 
ORDER BY joindate DESC;


37      Darren          Smith        2012-09-26 18:08:45
36      Erica           Crumpet      2012-09-22 08:36:38
35      John            Hunt         2012-09-19 11:32:45
33      Hyacinth        Tupperware   2012-09-18 19:32:05
30      Millicent       Purview      2012-09-18 19:04:01
... 




/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */


SELECT DISTINCT fac.name AS 'Facility',  CONCAT(mem.firstname, ' ', mem.surname) as 'Name'
FROM Bookings as bk
	INNER JOIN Facilities AS fac   ON bk.facid = fac.facid  -- USING facid
	INNER JOIN Members as mem     ON bk.memid = mem.memid   -- USING memid
WHERE 
	fac.name LIKE 'Tennis%'
	AND mem.firstname <> 'GUEST'
ORDER BY Name, fac.name;   -- sorts by first name, if that's okay.

# I made sure that a member using both tennis courts would show as two lines.
# Luckily that's how DISTINCT works in typical usage.
# Some members only used one court ever. Most have used both.
# Note: I assumed "GUEST" wouldn't be an informative member, probably the 
#   result of a data entry test, so removed.
# Note: There are two "Darren Smith" members. Same person who relocated? Different?
#   I didn't take any special action to deal with this, for now. 

Tennis Court 1	Anne Baker
Tennis Court 2	Anne Baker
Tennis Court 1	Burton Tracy
Tennis Court 2	Burton Tracy
Tennis Court 1	Charles Owen
Tennis Court 2	Charles Owen
Tennis Court 2	Darren Smith
Tennis Court 1	David Farrell
Tennis Court 2	David Farrell
Tennis Court 1	David Jones
Tennis Court 2	David Jones
Tennis Court 1	David Pinker
Tennis Court 1	Douglas Jones
Tennis Court 1	Erica Crumpet
Tennis Court 1	Florence Bader
Tennis Court 2	Florence Bader
...




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


<<<<< attempt 1: FAIL! >>>>>> no worky, syntax error 

SELECT fac.name,  CONCAT(mem.firstname, mem.surname), cost
FROM Bookings AS bk 
LEFT JOIN Facilities AS fac ON fac.facid = bk.facid
LEFT JOIN Members AS mem ON mem.memid = bk.memid
WHERE bk.starttime LIKE '2012-09-14%'
  AND (bk.slots * 
		(CASE 
			WHEN bk.memid = 0  THEN fac.guestcost 
			ELSE  fac.membercost 
		END))  AS cost
	 > 30
ORDER BY cost; 



<<<<< attempt 2: YAY! >>>>>>  aha, this works!  
 compute messy thing in SELECT, give it a name using 'AS',  
 and to my surprise, it's useable in the WHERE 
Update: after a long dialog with ChatGPT, which is smarter than I 
am when it comes to SQL, this "attempt 2" is incorrect, should not work
but happens to work due to quirks of SQLite. It's not portable!


SELECT 
    fac.name,  
    CONCAT(mem.firstname, mem.surname) AS name, 
    bk.slots * (CASE 
                  WHEN bk.memid =0  THEN fac.guestcost 
                  ELSE  fac.membercost 
	          END)  AS cost
FROM Bookings AS bk 
LEFT JOIN Facilities AS fac ON fac.facid = bk.facid
LEFT JOIN Members AS mem ON mem.memid = bk.memid
WHERE bk.starttime LIKE '2012-09-14%'
  AND cost > 30
ORDER BY cost; 


name            name           cost
Squash Court    GUESTGUEST       35.0
Squash Court    GUESTGUEST       35.0
Massage Room 1  JemimaFarrell    39.6
Squash Court    GUESTGUEST       70.0
Tennis Court 1  GUESTGUEST       75
Tennis Court 1  GUESTGUEST       75
Tennis Court 2  GUESTGUEST       75
Tennis Court 2  GUESTGUEST      150
Massage Room 1  GUESTGUEST      160
Massage Room 1  GUESTGUEST      160
Massage Room 1  GUESTGUEST      160
Massage Room 2  GUESTGUEST      320





/* Q9: This time, produce the same result as in Q8, but using a subquery. */


WITH info_with_costs AS (
   SELECT 
        fac.name AS name,  
        CONCAT(mem.firstname, mem.surname) AS membername, 
        bk.slots * (
            CASE 
                WHEN bk.memid = 0 THEN fac.guestcost 
                ELSE fac.membercost 
            END
        ) AS cost
   FROM Bookings AS bk
   LEFT JOIN Facilities AS fac ON fac.facid = bk.facid
   LEFT JOIN Members AS mem ON mem.memid = bk.memid
   WHERE bk.starttime LIKE '2012-09-14%'
)

SELECT 
    name,
    membername,
    cost
FROM info_with_costs
WHERE cost > 30
ORDER BY cost;




Squash Court	GUESTGUEST	35.0
Squash Court	GUESTGUEST	35.0
Massage Room 1	JemimaFarrell	39.6
Squash Court	GUESTGUEST	70.0
Tennis Court 1	GUESTGUEST	75
Tennis Court 1	GUESTGUEST	75
Tennis Court 2	GUESTGUEST	75
Tennis Court 2	GUESTGUEST	150
Massage Room 1	GUESTGUEST	160
Massage Room 1	GUESTGUEST	160
Massage Room 1	GUESTGUEST	160
Massage Room 2	GUESTGUEST	320




/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SQL in Jupyter notebook.
result: 
(8, 'Pool Table', 270)
(7, 'Snooker Table', 240)
(3, 'Table Tennis', 180)



/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

result start off like: 
Member                  Recommender           
Bader, Florence         Stibbons, Ponder      
Baker, Anne             Stibbons, Ponder      
Baker, Timothy          Farrell, Jemima       
Boothe, Tim             Rownam, Tim
...





/* Q12: Find the facilities with their usage by member, but not guests */

SQL in jupyter notebook.

result:
(2, 'Badminton Court', 1086)
(0, 'Tennis Court 1', 957)
(4, 'Massage Room 1', 884)
(1, 'Tennis Court 2', 882)
(7, 'Snooker Table', 860)
(8, 'Pool Table', 856)
(3, 'Table Tennis', 794)
(6, 'Squash Court', 418)
(5, 'Massage Room 2', 54)




/* Q13: Find the facilities usage by month, but not guests */
(Stashing this here for future ref. Official answer, the same as this, is
in the jupyter notebook.) 

WITH withmonths AS (
   SELECT  
		substr('JanFebMarAprMayJunJulAugSepOctNovDec', 
		      1 + 3*strftime('%m',starttime),
		      -3)  AS month,
		fac.facid AS facid, 
		fac.name  AS facname,		
		bk.memid AS memid, 
		bk.slots AS slots
   FROM Bookings      AS bk
      JOIN Facilities AS fac  ON fac.facid = bk.facid
      JOIN Members    AS mem  ON mem.memid = bk.memid
   WHERE bk.memid > 0    -- don't count guests, only members
)

SELECT month, sum(slots) as total_slots    -- facid, facname, SUM(slots)
FROM withmonths
GROUP BY month
ORDER BY month;


month	total_slots
Aug	2531
Jul	1061
Sep	3199





---------------------------- cut - ignore this --------------------------
Hi Daren,

Thanks for reaching out about this!

In this case, in order to access the SQL server, you'll need to use the general login information. Students share the same login/password on 
sql.springboard.com 
To access, you can use the following credentials:

    Username: student
    Passowrd: learn_sql@springboard

Please be sure not to edit or change this credential as it is used by everyone. If these do not work, you can also try:

    Username: student_1
    Passowrd: learn_sql@springboard

    Username: student_2
    Passowrd: learn_sql@springboard

Hope this helps! Please let us know if any other questions or concerns come up along the way.
Have a lovely rest of your day.
Best,
Student Advising Team
learn_sql@springboard

#1045 Cannot log in to the MySQL server
 Connection for controluser as defined in your configuration failed. 

(is not bad uname/pw; that gives error:  Login without a password is forbidden by configuration) 