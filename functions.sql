

-- 1. Function:    
--------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalculateStayDuration (@AdmissionID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Duration INT;

    SELECT @Duration = DATEDIFF(DAY, AdmissionDate, ISNULL(DischargeDate, GETDATE()))
    FROM Admissions
    WHERE AdmissionID = @AdmissionID;

    RETURN ISNULL(@Duration, 0);
END;
GO

--------------------------------------------------
-- 2. Function
--------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GetPrescriptionTotalCost (@PrescriptionID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(10,2);

    SELECT @TotalCost = SUM(m.Cost)
    FROM PrescriptionDetails pd
    INNER JOIN Medication m ON pd.MedicationID = m.MedicationID
    WHERE pd.PrescriptionID = @PrescriptionID;

    RETURN ISNULL(@TotalCost, 0.00);
END;
GO

--------------------------------------------------
-- 3. Function:     
--------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GetPatientFullName (@PatientID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FullName NVARCHAR(100);

    SELECT @FullName = Name
    FROM Patients
    WHERE PatientID = @PatientID;

    RETURN ISNULL(@FullName, 'Patient Not Found');
END;
GO

--------------------------------------------------
-- 4. Function: إرجاع عدد المواعيد المحجوزة لطبيب معين في تاريخ محدد
--------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GetDoctorAppointmentsCount (@DoctorID INT, @AppDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    SELECT @Count = COUNT(*)
    FROM Appointments
    WHERE DoctorID = @DoctorID 
      AND CAST([Date] AS DATE) = @AppDate;

    RETURN ISNULL(@Count, 0);
END;
GO

--------------------------------------------------
-- 5. Inline Table-Valued Function: (Triage Level)
--------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_GetPatientsByTriageLevel (@TriageLevel INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ert.TriageID,
        p.PatientID,
        p.Name AS PatientName,
        ert.TriageLevel,
        ert.ArrivalTime,
        ert.[Status]
    FROM EmergencyRoomTriage ert
    INNER JOIN Patients p ON ert.PatientID = p.PatientID
    WHERE ert.TriageLevel = @TriageLevel
);
GO
