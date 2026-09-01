CREATE DATABASE healthcare_analytics;
USE health_analytics;

SELECT *FROM medical
LIMIT 10;

ALTER TABLE medical
CHANGE COLUMN Hipertension hypertension INT,
CHANGE COLUMN Handcap disability_count INT,
CHANGE COLUMN No_show no_show VARCHAR(3);

SELECT disability_count, COUNT(*)
FROM medical
GROUP BY disability_count;

SELECT ScheduledDay, AppointmentDay
FROM medical
LIMIT 10;

ALTER TABLE medical
ADD COLUMN ScheduledDay_clean DATETIME,
ADD COLUMN AppointmentDay_clean DATE;

SET sql_safe_updates = 0;

UPDATE medical 
SET ScheduledDay_clean = STR_TO_DATE(REPLACE(REPLACE(ScheduledDay, 'T',' '),'Z',' '),'%Y-%m-%d %H:%i:%s'),
	AppointmentDay_clean = STR_TO_DATE(REPLACE(REPLACE(AppointmentDay, 'T',' '),'Z',' '),'%Y-%m-%d %H:%i:%s');

ALTER TABLE medical
DROP COLUMN ScheduledDay,
DROP COLUMN AppointmentDay;

ALTER TABLE medical
CHANGE COLUMN ScheduledDay_clean ScheduledDay DATETIME,
CHANGE COLUMN AppointmentDay_clean AppointmentDay DATE;

SELECT MIN(AGE), MAX(AGE)
FROM medical;

DELETE FROM medical
WHERE AGE = -1;

ALTER TABLE medical
ADD COLUMN lead_time_days INT;

UPDATE medical
SET lead_time_days = DATEDIFF(AppointmentDay, DATE(ScheduledDay));

SELECT MIN(lead_time_days), MAX(lead_time_days)
FROM medical;
 
SELECT * FROM medical
WHERE lead_time_days < 0;
 
SET sql_safe_updates = 0;

DELETE FROM medical
WHERE lead_time_days < 0;
 
SELECT no_show, COUNT(*) AS total_appointments,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM medical),2) AS pct_of_total
FROM medical
GROUP BY no_show;

SELECT DAYNAME(AppointmentDay) AS appointment_day,
	COUNT(*) AS total_appointment,
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS rate_of_no_show
FROM medical
GROUP BY DAYNAME(AppointmentDay)
ORDER BY rate_of_no_show DESC;

SELECT 
	CASE
		WHEN lead_time_days = 0 THEN 'Same Day'
        WHEN lead_time_days BETWEEN 1 AND 3 THEN 'Short(1-3 days)'
        WHEN lead_time_days BETWEEN 4 AND 7 THEN 'within a week'
        ELSE 'long lead(8+ days)'
    END AS lead_time_bucket,
    COUNT(*) AS total_appointments,
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100/ count(*),2) AS no_show_rate
FROM medical
GROUP BY lead_time_bucket
ORDER BY no_show_rate DESC;

SELECT 
	CASE 
		WHEN Age BETWEEN 0 AND 12 THEN 'child' 
        WHEN Age BETWEEN 13 AND 19 THEN 'teen'
        WHEN Age BETWEEN 20 AND 39 THEN 'young adult'
        WHEN Age BETWEEN 40 AND 59 THEN 'adult'
        ELSE 'senior'
	END AS age_bucket,
	COUNT(*) AS total_appointments,
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END)*100/COUNT(*),2) AS no_show_rate
FROM medical
GROUP BY age_bucket
ORDER BY no_show_rate DESC;

SELECT CASE WHEN SMS_received = 1 THEN 'received SMS' ELSE 'No SMS' END AS sms_status,
	COUNT(*) AS total_appointments,
	ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END)*100/COUNT(*),2) AS no_show_rate
FROM medical
GROUP BY sms_status
ORDER BY no_show_rate DESC;

SELECT Neighbourhood,
	COUNT(*) AS total_appointments,
    ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100/ count(*),2) AS no_show_rate,
    RANK() OVER (ORDER BY ROUND(SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) * 100/ count(*),2) DESC) AS risk_rank
    FROM medical
    GROUP BY Neighbourhood
    HAVING COUNT(*) >= 100
    ORDER BY no_show_rate DESC
    LIMIT 15;

SELECT patientid, appointmentid, no_show, 
	COUNT(*) OVER (
		PARTITION BY PatientId 
		ORDER BY AppointmentDay
		ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS pior_appointments,
    SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER(
		PARTITION BY PatientId
		ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS pior_no_show
	FROM medical 
    ORDER BY PatientId, AppointmentDay;

CREATE VIEW v_appointment_risk AS
WITH patient_history AS (
	SELECT PatientId, AppointmentID, AppointmentDay, Neighbourhood,
		lead_time_days, sms_received, Scholarship, no_show,
	COUNT(*) OVER (
		PARTITION BY PatientId 
		ORDER BY AppointmentDay
		ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS pior_appointments,
	SUM(CASE WHEN no_show = 'Yes' THEN 1 ELSE 0 END) OVER(
		PARTITION BY PatientId
		ORDER BY AppointmentDay
        ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS pior_no_show
	FROM medical
)
	SELECT PatientId, AppointmentID, AppointmentDay, Neighbourhood,
		lead_time_days, pior_appointments, pior_no_show,
        ROUND(pior_no_show/ NULLIF(pior_appointments, 0), 2) AS pior_no_show_rate,
        CASE 
			WHEN pior_appointments=0 THEN 'New Patient - Monitor'
            WHEN (pior_no_show/ NULLIF(pior_appointments, 0))>=0.5
				OR lead_time_days >=8 THEN 'High Risk'
			WHEN (pior_no_show/ NULLIF(pior_appointments, 0))>=0.2
				OR lead_time_days BETWEEN 4 AND 7 THEN 'Medium Risk'
			ELSE 'Lpw Risk'
		END AS risk_tier
	FROM patient_history;
        
SELECT * FROM v_appointment_risk 
WHERE risk_tier = 'High Risk'
ORDER BY AppointmentDay
LIMIT 50;

SELECT * FROM medical;
SELECT * FROM v_appointment_risk;


