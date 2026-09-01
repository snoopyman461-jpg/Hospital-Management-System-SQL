USE HospitalManagementSystem;
GO
-- 1.Trigger
CREATE OR ALTER TRIGGER dbo.trg_AfterAdmission_OccupyRoom
ON Admissions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Room
    SET Is_Available = 0
    FROM Room r
    INNER JOIN inserted i ON r.RoomID = i.RoomID;
END;
-- 2. Trigger: (AFTER UPDATE)
CREATE OR ALTER TRIGGER dbo.trg_AfterDischarge_FreeRoom
ON Admissions
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(DischargeDate)
    BEGIN
        UPDATE Room
        SET Is_Available = 1
        FROM Room r
        INNER JOIN inserted i ON r.RoomID = i.RoomID
        WHERE i.DischargeDate IS NOT NULL;
    END
END;

-- 3. Trigger

CREATE OR ALTER TRIGGER dbo.trg_InsteadOfInsert_CheckRoomAvailability
ON Admissions
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
س    IF EXISTS 
    (
        SELECT 1 
        FROM inserted i
        INNER JOIN Room r ON i.RoomID = r.RoomID
        WHERE r.Is_Available = 0
    )
    BEGIN
        RAISERROR('Cannot admit patient. One or more selected rooms are already occupied.', 16, 1);
        RETURN;
    END
    INSERT INTO Admissions (PatientID, RoomID, AdmissionDate, DischargeDate)
    SELECT PatientID, RoomID, AdmissionDate, DischargeDate
    FROM inserted;
END;
-- 4. Trigger
CREATE OR ALTER TRIGGER dbo.trg_PreventDeletePaidBills
ON PatientBills
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS 
    (
        SELECT 1 
        FROM deleted 
        WHERE PaidStatus = 'Paid'
    )
    BEGIN
        RAISERROR('Cannot delete a bill that has already been paid.', 16, 1);
        RETURN;
    END
    DELETE FROM PatientBills
    WHERE BillID IN (SELECT BillID FROM deleted);
END;
-- 5. Trigger
CREATE OR ALTER TRIGGER dbo.trg_AfterPrescription_CompleteAppointment
ON Prescriptions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Appointments
    SET [Status] = 'Completed'
    FROM Appointments a
    INNER JOIN inserted i ON a.AppointmentID = i.AppointmentID;
END;