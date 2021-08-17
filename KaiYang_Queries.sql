-- Settings for SQL Plus
SET LINESIZE 120
SET PAGESIZE 50
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY';

-- Setting current time
SET TERMOUT OFF
BREAK ON TODAY
COLUMN TODAY NEW_VALUE _DATE
SELECT TO_CHAR(SYSDATE, 'fmMonth DD, YYYY') TODAY
FROM DUAL;
CLEAR BREAKS
SET TERMOUT ON
SET VERIFY OFF

-------------------------------------- QUERY 1 -----------------------------------------

-- Taking User Input
PROMPT QUERY 1 - Check workload for staffs according to their position.
PROMPT
PROMPT Available Positions: [Cleaner, Doctor, Warehouse Manager, Specialist, Nurse, IT Support]
PROMPT
ACCEPT v_position CHAR FORMAT A30           PROMPT 'Enter the Staff Position(in lowercase): '

-- Setting the Titles
TTITLE CENTER '========================================================================================================================' SKIP 2 -
CENTER '---------------------------------------' SKIP 1 -
CENTER '--- Disease Management System (DMS) ---' SKIP 1 -
CENTER '---------------------------------------' SKIP 2 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 1 -
LEFT '--- ' _DATE CENTER 'Check Workload of Staff based on &v_position' RIGHT 'PAGE: ' SQL.PNO ' ---' SKIP 1 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 2 
BTITLE '' SKIP 1 -
CENTER 'Malaysia Disease Relief and Management Team (MDRMT)' SKIP 2 -
CENTER '========================================================================================================================'

-- Formatting the Result
COLUMN staff_id            FORMAT 9999          HEADING "Staff ID" JUSTIFY CENTER
COLUMN name                FORMAT A25           HEADING "Doctor Name" JUSTIFY CENTER
COLUMN WorkloadCount       FORMAT 99            HEADING "Number of Workload" JUSTIFY CENTER
BREAK ON WorkloadCount

-- Query 1 - Check workload for each position
SELECT COUNT(W.task_id) AS WorkloadCount, S.name, S.staff_id 
FROM Staffs S, Workload W 
WHERE S.staff_id = W.staff_id 
AND LOWER(S.position) = '&v_position'
GROUP BY S.staff_id, S.name, S.position 
ORDER BY WorkloadCount DESC;

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF

-------------------------------------- QUERY 2 -----------------------------------------

-- Taking User Input
PROMPT QUERY 2 - Check Number of COVID Victims more than average from each hospital where age lesser than user specified age.
PROMPT
PROMPT Available Diseases: [HIV, SARS, MERS, COVID-19, DENV]
PROMPT
ACCEPT v_disease  CHAR   FORMAT A30           PROMPT 'Enter the Disease: '
ACCEPT v_age      NUMBER FORMAT 99            PROMPT 'Enter the Age: '

-- Setting the Titles
TTITLE CENTER '========================================================================================================================' SKIP 2 -
CENTER '---------------------------------------' SKIP 1 -
CENTER '--- Disease Management System (DMS) ---' SKIP 1 -
CENTER '---------------------------------------' SKIP 2 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 1 -
LEFT '--- ' _DATE CENTER 'Check No of COVID Victims more than average where age lesser than &v_age' RIGHT 'PAGE: ' SQL.PNO ' ---' SKIP 1 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 2 
BTITLE '' SKIP 1 -
CENTER 'Malaysia Disease Relief and Management Team (MDRMT)' SKIP 2 -
CENTER '========================================================================================================================'

-- Formatting the Result
COLUMN DiseaseName         FORMAT A35            HEADING "Disease Name" JUSTIFY CENTER
COLUMN name                FORMAT A40           HEADING "Hospital Name" JUSTIFY CENTER
COLUMN NoOfCOVIDVictims    FORMAT 9999          HEADING "Number of COVID-19 Victims" JUSTIFY CENTER
BREAK ON DiseaseName

-- Query 2 - Check Number of COVID Victims more than average from each hospital where age lesser than age specified by user
SELECT D.name AS DiseaseName, S.name, COUNT(V.victim_id) AS NoOfCOVIDVictims 
FROM Victims V, Shelter_allocations SA, Shelters S, Disease_identifications DI, Diseases D 
WHERE V.victim_id = SA.victim_id AND SA.shelter_id = S.shelter_id 
AND D.disease_id = DI.disease_id AND DI.victim_id = V.victim_id AND (SELECT TRUNC((SYSDATE - TO_DATE(V.birth_date, 'DD-MON-YYYY'))/365.25) 
                                                                FROM DUAL) < &v_age 
AND (SELECT COUNT(victim_id) 
     FROM victims) > (SELECT AVG(VictimsCount) 
                      FROM (SELECT V.victim_id, COUNT(V.victim_id) AS VictimsCount 
                      FROM Victims V, Disease_identifications DI, Diseases D 
                      WHERE V.victim_id = DI.victim_id AND D.disease_id = DI.disease_id 
                      GROUP BY V.victim_id)) 
AND D.name LIKE '%&v_disease%' 
GROUP BY D.name, S.name
ORDER BY NoOfCOVIDVictims DESC;

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF

-------------------------------------- QUERY 3 -----------------------------------------

-- Taking User Input
PROMPT QUERY 3 - Report of items received through donations between user defined date.
PROMPT
PROMPT Available Items: [Face Mask, Surgical Mask, Blood Bag, Thermometer, Syringe, Rubber gloves, Surgical caps, Bandage, Stethoscopes, Dopplers]
PROMPT (leave blank if all items are needed)
PROMPT
PROMPT Example Start/End Date: 01-MAR-2017
PROMPT
ACCEPT v_start_date  CHAR   FORMAT A30           PROMPT 'Enter the Start Date: '
ACCEPT v_end_date    CHAR   FORMAT A30           PROMPT 'Enter the End Date: '
ACCEPT v_item_name   CHAR   FORMAT A50           PROMPT 'Enter the Item Name(in lowercase): '

-- Setting the Titles
TTITLE CENTER '========================================================================================================================' SKIP 2 -
CENTER '---------------------------------------' SKIP 1 -
CENTER '--- Disease Management System (DMS) ---' SKIP 1 -
CENTER '---------------------------------------' SKIP 2 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 1 -
LEFT '--- ' _DATE CENTER 'Report of items received through donations between &v_start_date and &v_end_date' RIGHT 'PAGE: ' SQL.PNO ' ---' SKIP 1 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 2 
BTITLE '' SKIP 1 -
CENTER 'Malaysia Disease Relief and Management Team (MDRMT)' SKIP 2 -
CENTER '========================================================================================================================'

-- Formatting the Result
COLUMN item_id               FORMAT 9999          HEADING "Item ID" JUSTIFY CENTER
COLUMN name                  FORMAT A40           HEADING "Item Name" JUSTIFY CENTER
COLUMN TotalNumOfDonation    FORMAT 9999          HEADING "Total Numbers of Items" JUSTIFY CENTER

-- Query 3 - Report of items received through donations between user defined date.
SELECT I.item_id, I.name, SUM(DI.quantity_donated) AS TotalNumOfDonation 
FROM Donations D, Donation_items DI, Items I 
WHERE D.donation_id = DI.donation_id AND DI.item_id = I.item_id 
AND D.date_donated BETWEEN TO_DATE('&v_start_date', 'DD-MON-YYYY') AND TO_DATE('&v_end_date', 'DD-MON-YYYY') 
AND LOWER(I.name) LIKE '%&v_item_name%' 
GROUP BY I.item_id, I.name 
ORDER BY TotalNumOfDonation DESC;

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF

-------------------------------------- QUERY 4 -----------------------------------------

-- Taking User Input
PROMPT QUERY 4 - Check victims details for a given shelter between user defined date.
PROMPT
PROMPT Available Status: [PENDING, RECOVERED, SERIOUS, DEATH]
PROMPT Available Shelters: [Beacon Hospital, Salam Medical Centre, Hospital Marudi, Hospital Pasir Mas, ...]
PROMPT (leave blank if all shelters are needed)
PROMPT 
PROMPT Example Start/End Date: 01-MAR-2017
PROMPT
ACCEPT v_start_date  CHAR   FORMAT A30           PROMPT 'Enter the Start Date: '
ACCEPT v_end_date    CHAR   FORMAT A30           PROMPT 'Enter the End Date: '
ACCEPT v_hospital    CHAR   FORMAT A50           PROMPT 'Enter the Hospital Name(in lowercase): '
ACCEPT v_status      CHAR   FORMAT A50           PROMPT 'Enter the status(in lowercase): '

-- Setting the Titles
TTITLE CENTER '========================================================================================================================' SKIP 2 -
CENTER '---------------------------------------' SKIP 1 -
CENTER '--- Disease Management System (DMS) ---' SKIP 1 -
CENTER '---------------------------------------' SKIP 2 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 1 -
LEFT '--- ' _DATE CENTER 'Check victims details for a given shelter between &v_start_date and &v_end_date' RIGHT 'PAGE: ' SQL.PNO ' ---' SKIP 1 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 2 
BTITLE '' SKIP 1 -
CENTER 'Malaysia Disease Relief and Management Team (MDRMT)' SKIP 2 -
CENTER '========================================================================================================================'

-- Formatting the Result
COLUMN status                FORMAT A20           HEADING "Victim Status" JUSTIFY CENTER
COLUMN name                  FORMAT A50           HEADING "Shelter Name" JUSTIFY CENTER
COLUMN VictimsCount          FORMAT 9999          HEADING "Total number of &v_status victims" JUSTIFY CENTER
BREAK ON status

-- Query 4 - Check how many victims are still pending for their disease identification for a given hospital in the past 7 days.
SELECT V.status, S.name, COUNT(SA.victim_id) AS VictimsCount 
FROM Shelters S, Shelter_allocations SA, Victims V 
WHERE S.shelter_id = SA.shelter_id AND SA.victim_id = V.victim_id 
AND V.date_admitted BETWEEN TO_DATE('&v_start_date', 'DD-MON-YYYY') AND TO_DATE('&v_end_date', 'DD-MON-YYYY') 
AND LOWER(V.status) LIKE '&v_status' 
AND LOWER(S.name) LIKE '%&v_hospital%' 
GROUP BY V.status, S.name 
ORDER BY VictimsCount DESC;

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF

-------------------------------------- QUERY 5 -----------------------------------------

-- Taking User Input
PROMPT QUERY 5 - Report of total items allocated to each shelter between a user defined date.
PROMPT
PROMPT Example Start/End Date: 01-MAR-2017
PROMPT
ACCEPT v_start_date  CHAR   FORMAT A30           PROMPT 'Enter the Start Date: '
ACCEPT v_end_date    CHAR   FORMAT A30           PROMPT 'Enter the End Date: '

-- Setting the Titles
TTITLE CENTER '========================================================================================================================' SKIP 2 -
CENTER '---------------------------------------' SKIP 1 -
CENTER '--- Disease Management System (DMS) ---' SKIP 1 -
CENTER '---------------------------------------' SKIP 2 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 1 -
LEFT '--- ' _DATE CENTER 'Total items allocated to each shelter between &v_start_date and &v_end_date' RIGHT 'PAGE: ' SQL.PNO ' ---' SKIP 1 -
CENTER '------------------------------------------------------------------------------------------------------------------------' SKIP 2 
BTITLE '' SKIP 1 -
CENTER 'Malaysia Disease Relief and Management Team (MDRMT)' SKIP 2 -
CENTER '========================================================================================================================'

-- Formatting the Result
COLUMN shelter_id            FORMAT 9999          HEADING "Shelter ID" JUSTIFY CENTER
COLUMN name                  FORMAT A50           HEADING "Shelter Name" JUSTIFY CENTER
COLUMN TotalNumOfAllocated   FORMAT 9999          HEADING "Total number of items allocated" JUSTIFY CENTER

-- Query 5 - Report of total items allocated to each shelter between a user defined date.
SELECT S.shelter_id, S.name, SUM(IA.quantity_allocated) AS TotalNumOfAllocated 
FROM Items I, Item_allocations IA, Shelters S 
WHERE I.item_id = IA.item_id AND IA.shelter_id = S.shelter_id 
AND IA.date_allocated BETWEEN TO_DATE('&v_start_date', 'DD-MON-YYYY') AND TO_DATE('&v_end_date', 'DD-MON-YYYY') 
GROUP BY S.shelter_id, S.name 
ORDER BY TotalNumOfAllocated DESC;

CLEAR COLUMNS
TTITLE OFF
BTITLE OFF
