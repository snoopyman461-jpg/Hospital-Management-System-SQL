USE HospitalManagementSystem;
GO
-- PART 1: BUSINESS QUERIES & ANALYTICAL REPORTS
SELECT 
    a.AppointmentID,
    p.Name AS PatientName,
    p.Phone AS PatientPhone,
    d.Name AS DoctorName,
    d.Specialty,
    a.[Date] AS AppointmentDate,
    a.[Time] AS AppointmentTime,
    a.[Status]
FROM Appointments a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctor d ON a.DoctorID = d.DoctorID
ORDER BY a.[Date] DESC, a.[Time] ASC;
-- 2.(Paid vs Unpaid vs Pending)
SELECT 
    PaidStatus,
    COUNT(BillID) AS TotalBillsCount,
    SUM(TotalAmount) AS TotalRevenue
FROM PatientBills
GROUP BY PaidStatus;

-- 3.(Active Admissions)
SELECT 
    adm.AdmissionID,
    p.Name AS PatientName,
    r.RoomID,
    r.RoomType,
    adm.AdmissionDate,
    DATEDIFF(DAY, adm.AdmissionDate, GETDATE()) AS DaysInHospital
FROM Admissions adm
INNER JOIN Patients p ON adm.PatientID = p.PatientID
INNER JOIN Room r ON adm.RoomID = r.RoomID
WHERE adm.DischargeDate IS NULL;

-- 4. -- Statistics on the number of examinations and appointments for each doctor
SELECT 
    d.DoctorID,
    d.Name AS DoctorName,
    d.Specialty,
    COUNT(a.AppointmentID) AS TotalAppointments,
    SUM(CASE WHEN a.[Status] = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
    SUM(CASE WHEN a.[Status] = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments
FROM Doctor d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.Name, d.Specialty;

-- 5. -- Display full details of the prescription, prescribed medications, dosages, and total cost
SELECT 
    pr.PrescriptionID,
    p.Name AS PatientName,
    d.Name AS DoctorName,
    m.Name AS MedicationName,
    pd.Dose,
    pd.Frequency,
    m.Cost
FROM Prescriptions pr
INNER JOIN Appointments a ON pr.AppointmentID = a.AppointmentID
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctor d ON a.DoctorID = d.DoctorID
INNER JOIN PrescriptionDetails pd ON pr.PrescriptionID = pd.PrescriptionID
INNER JOIN Medication m ON pd.MedicationID = m.MedicationID;

-- 6.  (Triage Level 1 & 2) 
SELECT 
    ert.TriageID,
    p.Name AS PatientName,
    ert.TriageLevel,
    ert.ArrivalTime,
    ert.[Status]
FROM EmergencyRoomTriage ert
INNER JOIN Patients p ON ert.PatientID = p.PatientID
WHERE ert.TriageLevel IN (1, 2) 
  AND ert.[Status] = 'Waiting'
ORDER BY ert.TriageLevel ASC, ert.ArrivalTime ASC;

-- 7. (Top Prescribed Medications)
SELECT 
    m.MedicationID,
    m.Name AS MedicationName,
    m.Cost,
    COUNT(pd.PrescriptionID) AS TimesPrescribed
FROM Medication m
LEFT JOIN PrescriptionDetails pd ON m.MedicationID = pd.MedicationID
GROUP BY m.MedicationID, m.Name, m.Cost
ORDER BY TimesPrescribed DESC;

-- 8.  (Subquery)
SELECT 
    p.PatientID,
    p.Name AS PatientName,
    SUM(pb.TotalAmount) AS TotalSpent
FROM Patients p
INNER JOIN PatientBills pb ON p.PatientID = pb.PatientID
GROUP BY p.PatientID, p.Name
HAVING SUM(pb.TotalAmount) > (SELECT AVG(TotalAmount) FROM PatientBills);

-- 9.  Window Functions (DENSE_RANK)
SELECT 
    d.DoctorID,
    d.Name AS DoctorName,
    COUNT(DISTINCT a.PatientID) AS UniquePatients,
    DENSE_RANK() OVER (ORDER BY COUNT(DISTINCT a.PatientID) DESC) AS DoctorRank
FROM Doctor d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.Name;

-- 10.  (CTE)
WITH DischargedPatientsCTE AS (
    SELECT 
        adm.AdmissionID,
        adm.PatientID,
        DATEDIFF(DAY, adm.AdmissionDate, adm.DischargeDate) AS StayDays
    FROM Admissions adm
    WHERE adm.DischargeDate IS NOT NULL
)
SELECT 
    p.Name AS PatientName,
    cte.StayDays,
    pb.TotalAmount AS BillAmount
FROM DischargedPatientsCTE cte
INNER JOIN Patients p ON cte.PatientID = p.PatientID
LEFT JOIN PatientBills pb ON cte.AdmissionID = pb.AdmissionID;
GO
-- PART 2: DATABASE VIEWS
CREATE OR ALTER VIEW dbo.vw_RoomStatusReport
AS
SELECT 
    r.RoomID,
    r.RoomType,
    CASE WHEN r.Is_Available = 1 THEN 'Available' ELSE 'Occupied' END AS AvailabilityStatus,
    p.Name AS CurrentPatient,
    adm.AdmissionDate
FROM Room r
LEFT JOIN Admissions adm ON r.RoomID = adm.RoomID AND adm.DischargeDate IS NULL
LEFT JOIN Patients p ON adm.PatientID = p.PatientID;
GO

