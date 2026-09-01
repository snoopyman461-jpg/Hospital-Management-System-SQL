USE HospitalManagementSystem;
GO
CREATE OR ALTER VIEW dbo.vw_TodayAppointments
AS
SELECT 
    a.AppointmentID,
    a.[Date] AS AppointmentDate,
    a.[Time] AS AppointmentTime,
    a.[Status],
    p.PatientID,
    p.Name AS PatientName,
    p.Phone AS PatientPhone,
    d.DoctorID,
    d.Name AS DoctorName,
    d.Specialty AS DoctorSpecialty
FROM Appointments a
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctor d ON a.DoctorID = d.DoctorID
WHERE a.[Date] = CAST(GETDATE() AS DATE);
GO
-- 2. View: vw_RevenueBySpecialty
CREATE OR ALTER VIEW dbo.vw_RevenueBySpecialty
AS
SELECT 
    d.Specialty,
    COUNT(DISTINCT a.AppointmentID) AS TotalAppointmentsCount,
    ISNULL(SUM(pb.TotalAmount), 0) AS TotalRevenueGenerated
FROM Doctor d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
LEFT JOIN Prescriptions pr ON a.AppointmentID = pr.AppointmentID
LEFT JOIN PatientBills pb ON a.PatientID = pb.PatientID
WHERE pb.PaidStatus = 'Paid' OR pb.PaidStatus IS NULL
GROUP BY d.Specialty;
GO
-- 3. View: vw_PatientBills
CREATE OR ALTER VIEW dbo.vw_PatientBills
AS
SELECT 
    pb.BillID,
    p.PatientID,
    p.Name AS PatientName,
    pb.[Date] AS BillDate,
    pb.PaidStatus,
    pb.TotalAmount AS GrossTotalAmount,
    ISNULL(
        (SELECT SUM(m.Cost) 
         FROM Prescriptions pr 
         INNER JOIN Appointments app ON pr.AppointmentID = app.AppointmentID 
         INNER JOIN PrescriptionDetails pd ON pr.PrescriptionID = pd.PrescriptionID 
         INNER JOIN Medication m ON pd.MedicationID = m.MedicationID 
         WHERE app.PatientID = p.PatientID), 0
    ) AS EstimatedPrescriptionCost,
    CASE 
        WHEN pb.PaidStatus = 'Paid' THEN 0.00
        ELSE pb.TotalAmount 
    END AS OutstandingBalance
FROM PatientBills pb
INNER JOIN Patients p ON pb.PatientID = p.PatientID;
GO
-- 4. View: vw_ActiveRoomAdmissions
CREATE OR ALTER VIEW dbo.vw_ActiveRoomAdmissions
AS
SELECT 
    r.RoomID,
    r.RoomType,
    adm.AdmissionID,
    p.PatientID,
    p.Name AS PatientName,
    p.Phone AS PatientPhone,
    adm.AdmissionDate,
    DATEDIFF(DAY, adm.AdmissionDate, GETDATE()) AS DaysAdmitted
FROM Room r
INNER JOIN Admissions adm ON r.RoomID = adm.RoomID
INNER JOIN Patients p ON adm.PatientID = p.PatientID
WHERE adm.DischargeDate IS NULL AND r.Is_Available = 0;
GO
-- 5. View: vw_DoctorWorkload
CREATE OR ALTER VIEW dbo.vw_DoctorWorkload
AS
SELECT 
    d.DoctorID,
    d.Name AS DoctorName,
    d.Specialty,
    YEAR(a.[Date]) AS WorkYear,
    MONTH(a.[Date]) AS WorkMonth,
    COUNT(a.AppointmentID) AS TotalMonthlyAppointments,
    COUNT(DISTINCT a.PatientID) AS UniquePatientsServiced
FROM Doctor d
LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorID, d.Name, d.Specialty, YEAR(a.[Date]), MONTH(a.[Date]);
GO
-- View 2: ملخص حسابات وفواتير المرضى
CREATE OR ALTER VIEW dbo.vw_PatientBillingSummary
AS
SELECT 
    p.PatientID,
    p.Name AS PatientName,
    p.Phone,
    COUNT(pb.BillID) AS TotalBills,
    ISNULL(SUM(pb.TotalAmount), 0) AS GrandTotal,
    ISNULL(SUM(CASE WHEN pb.PaidStatus = 'Paid' THEN pb.TotalAmount ELSE 0 END), 0) AS PaidAmount,
    ISNULL(SUM(CASE WHEN pb.PaidStatus = 'Unpaid' THEN pb.TotalAmount ELSE 0 END), 0) AS UnpaidAmount
FROM Patients p
LEFT JOIN PatientBills pb ON p.PatientID = pb.PatientID
GROUP BY p.PatientID, p.Name, p.Phone;
GO

-- View 3: سجل العيادات والروشتات اليومية
CREATE OR ALTER VIEW dbo.vw_DailyPrescriptionLog
AS
SELECT 
    pr.PrescriptionID,
    pr.[Date] AS PrescriptionDate,
    p.Name AS PatientName,
    d.Name AS DoctorName,
    dbo.fn_GetPrescriptionTotalCost(pr.PrescriptionID) AS TotalPrescriptionCost
FROM Prescriptions pr
INNER JOIN Appointments a ON pr.AppointmentID = a.AppointmentID
INNER JOIN Patients p ON a.PatientID = p.PatientID
INNER JOIN Doctor d ON a.DoctorID = d.DoctorID;
GO















