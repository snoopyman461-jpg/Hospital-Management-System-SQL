USE HospitalManagementSystem;
GO
-- 1. Stored Procedure
CREATE OR ALTER PROCEDURE dbo.sp_BookAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATE,
    @AppointmentTime TIME,
    @Status NVARCHAR(50) = 'Scheduled'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM Patients WHERE PatientID = @PatientID)
            THROW 50001, 'Patient ID does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Doctor WHERE DoctorID = @DoctorID)
            THROW 50002, 'Doctor ID does not exist.', 1;
        INSERT INTO Appointments (PatientID, DoctorID, [Date], [Time], [Status])
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @AppointmentTime, @Status);

        COMMIT TRANSACTION;
        PRINT 'Appointment booked successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- 2. Stored Procedure: (Admission)
CREATE OR ALTER PROCEDURE dbo.sp_AdmitPatient
    @PatientID INT,
    @RoomID INT,
    @AdmissionDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @IsAvailable BIT;
        SELECT @IsAvailable = Is_Available FROM Room WHERE RoomID = @RoomID;

        IF @IsAvailable = 0 OR @IsAvailable IS NULL
            THROW 50003, 'Room is currently not available.', 1;
        INSERT INTO Admissions (PatientID, RoomID, AdmissionDate)
        VALUES (@PatientID, @RoomID, @AdmissionDate);
        UPDATE Room
        SET Is_Available = 0
        WHERE RoomID = @RoomID;
        COMMIT TRANSACTION;
        PRINT 'Patient admitted and room assigned successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- 3. Stored Procedure: (Discharge)
CREATE OR ALTER PROCEDURE dbo.sp_DischargePatient
    @AdmissionID INT,
    @DischargeDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @RoomID INT;
        SELECT @RoomID = RoomID FROM Admissions WHERE AdmissionID = @AdmissionID;

        IF @RoomID IS NULL
            THROW 50004, 'Admission record not found.', 1;
        UPDATE Admissions
        SET DischargeDate = @DischargeDate
        WHERE AdmissionID = @AdmissionID;
        UPDATE Room
        SET Is_Available = 1
        WHERE RoomID = @RoomID;
        COMMIT TRANSACTION;
        PRINT 'Patient discharged successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- 4. Stored Procedure
CREATE OR ALTER PROCEDURE dbo.sp_GenerateBill
    @PatientID INT,
    @AdmissionID INT = NULL,
    @TotalAmount DECIMAL(10,2),
    @PaidStatus NVARCHAR(50) = 'Unpaid'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO PatientBills (PatientID, AdmissionID, [Date], TotalAmount, PaidStatus)
        VALUES (@PatientID, @AdmissionID, GETDATE(), @TotalAmount, @PaidStatus);

        COMMIT TRANSACTION;
        PRINT 'Bill generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- 5. Stored Procedure:
CREATE OR ALTER PROCEDURE dbo.sp_CreatePrescriptionWithMedication
    @AppointmentID INT,
    @MedicationID INT,
    @Dose NVARCHAR(100),
    @Frequency NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @PrescriptionID INT;
        SELECT @PrescriptionID = PrescriptionID 
        FROM Prescriptions 
        WHERE AppointmentID = @AppointmentID;
        IF @PrescriptionID IS NULL
        BEGIN
            INSERT INTO Prescriptions (AppointmentID, [Date])
            VALUES (@AppointmentID, GETDATE());
            SET @PrescriptionID = SCOPE_IDENTITY();
        END
        INSERT INTO PrescriptionDetails (PrescriptionID, MedicationID, Dose, Frequency)
        VALUES (@PrescriptionID, @MedicationID, @Dose, @Frequency);
        COMMIT TRANSACTION;
        PRINT 'Medication added to prescription successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO





















USE HospitalManagementSystem;
GO

-- 1. Stored Procedure: sp_BookAppointment
CREATE OR ALTER PROCEDURE dbo.sp_BookAppointment
    @PatientID INT,
    @DoctorID INT,
    @AppointmentDate DATE,
    @AppointmentTime TIME,
    @Status NVARCHAR(50) = 'Scheduled'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Patients WHERE PatientID = @PatientID)
            THROW 50001, 'Patient ID does not exist.', 1;

        IF NOT EXISTS (SELECT 1 FROM Doctor WHERE DoctorID = @DoctorID)
            THROW 50002, 'Doctor ID does not exist.', 1;

        -- Validate doctor schedule availability (Check for time collision)
        IF EXISTS (
            SELECT 1 FROM Appointments 
            WHERE DoctorID = @DoctorID 
              AND [Date] = @AppointmentDate 
              AND [Time] = @AppointmentTime 
              AND [Status] != 'Cancelled'
        )
            THROW 50003, 'Doctor is not available at the selected date and time.', 1;

        INSERT INTO Appointments (PatientID, DoctorID, [Date], [Time], [Status])
        VALUES (@PatientID, @DoctorID, @AppointmentDate, @AppointmentTime, @Status);

        COMMIT TRANSACTION;
        PRINT 'Appointment booked successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 2. Stored Procedure: sp_AdmitPatient
CREATE OR ALTER PROCEDURE dbo.sp_AdmitPatient
    @PatientID INT,
    @RoomID INT,
    @AdmissionDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @IsAvailable BIT;
        SELECT @IsAvailable = Is_Available FROM Room WHERE RoomID = @RoomID;

        IF @IsAvailable = 0 OR @IsAvailable IS NULL
            THROW 50004, 'Room is currently not available.', 1;

        INSERT INTO Admissions (PatientID, RoomID, AdmissionDate)
        VALUES (@PatientID, @RoomID, @AdmissionDate);

        UPDATE Room
        SET Is_Available = 0
        WHERE RoomID = @RoomID;

        COMMIT TRANSACTION;
        PRINT 'Patient admitted and room assigned successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 3. Stored Procedure: sp_GenerateBill
CREATE OR ALTER PROCEDURE dbo.sp_GenerateBill
    @PatientID INT,
    @AdmissionID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @RoomCharge DECIMAL(10,2) = 0.00;
        DECLARE @MedicationCharge DECIMAL(10,2) = 0.00;
        DECLARE @TotalAmount DECIMAL(10,2) = 0.00;

        -- Aggregate room charges (Days * Daily Rate)
        IF @AdmissionID IS NOT NULL
        BEGIN
            SELECT @RoomCharge = ISNULL(DATEDIFF(DAY, adm.AdmissionDate, ISNULL(adm.DischargeDate, GETDATE())) * r.PricePerDay, 0.00)
            FROM Admissions adm
            INNER JOIN Room r ON adm.RoomID = r.RoomID
            WHERE adm.AdmissionID = @AdmissionID;
        END

        -- Aggregate prescribed medication costs
        SELECT @MedicationCharge = ISNULL(SUM(m.UnitPrice * pd.Quantity), 0.00)
        FROM Prescriptions pr
        INNER JOIN Appointments app ON pr.AppointmentID = app.AppointmentID
        INNER JOIN PrescriptionDetails pd ON pr.PrescriptionID = pd.PrescriptionID
        INNER JOIN Medication m ON pd.MedicationID = m.MedicationID
        WHERE app.PatientID = @PatientID;

        SET @TotalAmount = @RoomCharge + @MedicationCharge;

        INSERT INTO PatientBills (PatientID, AdmissionID, [Date], TotalAmount, PaidStatus)
        VALUES (@PatientID, @AdmissionID, GETDATE(), @TotalAmount, 'Unpaid');

        COMMIT TRANSACTION;
        PRINT 'Bill generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 4. Stored Procedure: sp_DischargePatient (Triggers sp_GenerateBill)
CREATE OR ALTER PROCEDURE dbo.sp_DischargePatient
    @AdmissionID INT,
    @DischargeDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @RoomID INT, @PatientID INT;
        SELECT @RoomID = RoomID, @PatientID = PatientID 
        FROM Admissions 
        WHERE AdmissionID = @AdmissionID;

        IF @RoomID IS NULL
            THROW 50005, 'Admission record not found.', 1;

        UPDATE Admissions
        SET DischargeDate = @DischargeDate
        WHERE AdmissionID = @AdmissionID;

        UPDATE Room
        SET Is_Available = 1
        WHERE RoomID = @RoomID;

        -- Auto-trigger bill generation upon discharge
        EXEC dbo.sp_GenerateBill @PatientID = @PatientID, @AdmissionID = @AdmissionID;

        COMMIT TRANSACTION;
        PRINT 'Patient discharged and bill generated successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 5. Stored Procedure: sp_ProcessBillPayment
CREATE OR ALTER PROCEDURE dbo.sp_ProcessBillPayment
    @BillID INT,
    @PaymentAmount DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @TotalAmount DECIMAL(10,2);
        SELECT @TotalAmount = TotalAmount FROM PatientBills WHERE BillID = @BillID;

        IF @TotalAmount IS NULL
            THROW 50006, 'Bill record not found.', 1;

        IF @PaymentAmount < @TotalAmount
            THROW 50007, 'Payment amount is insufficient for full settlement.', 1;

        UPDATE PatientBills
        SET PaidStatus = 'Paid'
        WHERE BillID = @BillID;

        -- Audit tracking log
        INSERT INTO PaymentAuditLog (BillID, PaymentDate, AmountPaid, Status)
        VALUES (@BillID, GETDATE(), @PaymentAmount, 'Success');

        COMMIT TRANSACTION;
        PRINT 'Payment processed and bill status updated to Paid.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO


