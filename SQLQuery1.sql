CREATE TABLE Doctors 
(
    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Specialty VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL
);
CREATE TABLE Patients 
(
    PatientID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female')),
    BirthDate DATE NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Address VARCHAR(255)
);
CREATE TABLE Appointments
(
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    DoctorID INT NOT NULL FOREIGN KEY REFERENCES Doctors(DoctorID),
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Patients(PatientID),
    Date DATE NOT NULL,
    Time TIME NOT NULL CHECK (Time BETWEEN '08:00' AND '20:00'),
    Status VARCHAR(20) DEFAULT 'Scheduled' CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled'))
);
CREATE TABLE Rooms
(
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    Type VARCHAR(50) NOT NULL,
    Available BIT DEFAULT 1
);
CREATE TABLE Admissions 
(
    AdmissionID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Patients(PatientID),
    RoomID INT NOT NULL FOREIGN KEY REFERENCES Rooms(RoomID),
    AdmissionDate DATE NOT NULL,
    DischargeDate DATE NULL,
    CONSTRAINT CK_DischargeDate CHECK (DischargeDate >= AdmissionDate)
);
CREATE TABLE Medications 
(
    MedicationID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Cost DECIMAL(10,2) CHECK (Cost >= 0)
);
CREATE TABLE Prescriptions 
(
    PrescriptionID INT IDENTITY(1,1) PRIMARY KEY,
    AppointmentID INT UNIQUE NOT NULL FOREIGN KEY REFERENCES Appointments(AppointmentID),
    Date DATE NOT NULL
);
CREATE TABLE PrescriptionDetails
(
    PrescriptionID INT NOT NULL FOREIGN KEY REFERENCES Prescriptions(PrescriptionID),
    MedicationID INT NOT NULL FOREIGN KEY REFERENCES Medications(MedicationID),
    Dosage INT CHECK (Dosage > 0),
    Frequency VARCHAR(50) NOT NULL,
    PRIMARY KEY (PrescriptionID, MedicationID)
);
CREATE TABLE Bills 
(
    BillID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Patients(PatientID),
    AdmissionID INT NULL FOREIGN KEY REFERENCES Admissions(AdmissionID),
    TotalAmount DECIMAL(10,2) CHECK (TotalAmount >= 0),
    PaidStatus BIT DEFAULT 0
);
CREATE TABLE ERTriage 
(
    TriageID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL FOREIGN KEY REFERENCES Patients(PatientID),
    TriageLevel INT CHECK (TriageLevel BETWEEN 1 AND 5),
    ArrivalTime DATETIME DEFAULT GETDATE(),
    Status VARCHAR(20) DEFAULT 'Waiting' CHECK (Status IN ('Waiting', 'In-Treatment', 'Discharged'))
);















INSERT INTO Doctors (Name, Specialty, Phone) VALUES 
('Dr. Ahmed Hassan', 'Cardiology', '01011111111'),
('Dr. Mona Ali', 'Pediatrics', '01022222222'),
('Dr. Khaled Omar', 'Orthopedics', '01033333333'),
('Dr. Sara Ibrahim', 'Neurology', '01044444444'),
('Dr. Mahmoud Youssef', 'General Surgery', '01055555555');
INSERT INTO Patients (Name, Gender, BirthDate, Phone, Address) VALUES 
('Youssef Mohamed', 'Male', '2005-01-15', '01066666666', 'Cairo'),
('Sara Mahmoud', 'Female', '1998-05-20', '01077777777', 'Giza'),
('Ali Hassan', 'Male', '1985-11-10', '01088888888', 'Alexandria'),
('Nour sameh', 'Male', '1992-03-30', '01099999999', 'Mansoura'),
('jana Adel', 'Female', '2001-08-12', '01111111111', 'Zagazig'),
('jana Khaled', 'Female', '1978-12-05', '01222222222', 'Tanta');
INSERT INTO Appointments (DoctorID, PatientID, Date, Time, Status) VALUES 
(1, 1, '2026-09-01', '10:00:00', 'Completed'),
(2, 2, '2026-09-02', '14:00:00', 'Scheduled'),
(3, 3, '2026-09-02', '11:30:00', 'Completed'),
(4, 4, '2026-09-03', '09:00:00', 'Cancelled'),
(5, 5, '2026-09-03', '16:00:00', 'Completed'),
(1, 6, '2026-09-04', '12:00:00', 'Scheduled');
INSERT INTO Medications (Name, Cost) VALUES 
('Panadol Extra', 25.50),
('Aspirin 100mg', 15.00),
('Amoxicillin 500mg', 45.00),
('Ibuprofen 400mg', 30.00),
('Omeprazole 20mg', 60.00),
('Voltaren Emulgel', 35.00);
INSERT INTO Prescriptions (AppointmentID, Date) VALUES 
(1, '2026-09-01'),
(3, '2026-09-02'),
(5, '2026-09-03');
INSERT INTO PrescriptionDetails (PrescriptionID, MedicationID, Dosage, Frequency) VALUES 
(1, 1, 2, 'Twice Daily'),
(1, 2, 1, 'Once Daily'),
(2, 4, 1, 'Every 8 Hours'),
(2, 6, 1, 'As Needed'),
(3, 3, 2, 'Three Times Daily'),
(3, 5, 1, 'Before Breakfast');
INSERT INTO Rooms (Type, Available) VALUES 
('ICU', 0),
('Single Standard', 1),
('Double Suite', 0),
('Single Standard', 1),
('VIP Suite', 0);
INSERT INTO Admissions (PatientID, RoomID, AdmissionDate, DischargeDate) VALUES 
(1, 1, '2026-08-20', '2026-08-25'),
(3, 3, '2026-08-26', NULL), 
(5, 5, '2026-08-28', NULL); 
INSERT INTO Bills (PatientID, AdmissionID, TotalAmount, PaidStatus) VALUES 
(1, 1, 3500.00, 1), 
(3, 2, 1800.50, 0), 
(5, 3, 5200.00, 0), 
(2, NULL, 250.00, 1); 
INSERT INTO ERTriage (PatientID, TriageLevel, ArrivalTime, Status) VALUES 
(2, 2, GETDATE(), 'Waiting'),
(4, 1, GETDATE(), 'In-Treatment'), 
(6, 4, GETDATE(), 'Waiting'),
(3, 3, GETDATE(), 'Discharged'),
(5, 2, GETDATE(), 'In-Treatment');













SELECT 
    A.AppointmentID,
    P.Name AS PatientName,
    D.Name AS DoctorName,
    D.Specialty,
    A.Date,
    A.Time
FROM Appointments A
JOIN Patients P ON A.PatientID = P.PatientID
JOIN Doctors D ON A.DoctorID = D.DoctorID
WHERE A.Status = 'Completed';
SELECT 
    P.Name AS PatientName,
    PR.PrescriptionID,
    M.Name AS MedicationName,
    PD.Dosage,
    PD.Frequency,
    M.Cost
FROM Prescriptions PR
JOIN Appointments A ON PR.AppointmentID = A.AppointmentID
JOIN Patients P ON A.PatientID = P.PatientID
JOIN PrescriptionDetails PD ON PR.PrescriptionID = PD.PrescriptionID
JOIN Medications M ON PD.MedicationID = M.MedicationID;
SELECT 
    E.TriageID,
    P.Name AS PatientName,
    E.TriageLevel,
    E.ArrivalTime,
    E.Status
FROM ERTriage E
JOIN Patients P ON E.PatientID = P.PatientID
WHERE E.Status IN ('Waiting', 'In-Treatment')
ORDER BY E.TriageLevel ASC, E.ArrivalTime ASC;
SELECT 
    P.Name AS PatientName,
    COUNT(B.BillID) AS TotalBills,
    SUM(B.TotalAmount) AS GrandTotal,
    SUM(CASE WHEN B.PaidStatus = 1 THEN B.TotalAmount ELSE 0 END) AS TotalPaid,
    SUM(CASE WHEN B.PaidStatus = 0 THEN B.TotalAmount ELSE 0 END) AS TotalUnpaid
FROM Bills B
JOIN Patients P ON B.PatientID = P.PatientID
GROUP BY P.Name;
SELECT 
    R.RoomID,
    R.Type AS RoomType,
    P.Name AS PatientName,
    ADM.AdmissionDate
FROM Admissions ADM
JOIN Rooms R ON ADM.RoomID = R.RoomID
JOIN Patients P ON ADM.PatientID = P.PatientID
WHERE ADM.DischargeDate IS NULL;











CREATE VIEW vw_AppointmentDetails AS
SELECT 
    A.AppointmentID,
    P.Name AS PatientName,
    D.Name AS DoctorName,
    D.Specialty,
    A.Date,
    A.Time,
    A.Status
FROM Appointments A
JOIN Patients P ON A.PatientID = P.PatientID
JOIN Doctors D ON A.DoctorID = D.DoctorID;
GO
CREATE VIEW vw_ActiveERTriage AS
SELECT 
    E.TriageID,
    P.Name AS PatientName,
    P.Phone,
    E.TriageLevel,
    E.ArrivalTime,
    E.Status
FROM ERTriage E
JOIN Patients P ON E.PatientID = P.PatientID
WHERE E.Status IN ('Waiting', 'In-Treatment');
GO

CREATE PROCEDURE sp_AddPatientToTriage
    @PatientID INT,
    @TriageLevel INT
AS
BEGIN
    INSERT INTO ERTriage (PatientID, TriageLevel, ArrivalTime, Status)
    VALUES (@PatientID, @TriageLevel, GETDATE(), 'Waiting');
END;
GO
CREATE PROCEDURE sp_DischargePatient
    @AdmissionID INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Admissions
        SET DischargeDate = GETDATE()
        WHERE AdmissionID = @AdmissionID;
        UPDATE Rooms
        SET Available = 1
        WHERE RoomID = (SELECT RoomID FROM Admissions WHERE AdmissionID = @AdmissionID);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE TRIGGER trg_PreventDoubleBooking
ON Appointments
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Appointments A
        JOIN inserted I ON A.DoctorID = I.DoctorID 
                       AND A.Date = I.Date 
                       AND A.Time = I.Time
        WHERE A.Status != 'Cancelled'
    )
    BEGIN
        RAISERROR ('The selected doctor is already booked for this date and time slot.', 16, 1);
    END
    ELSE
    BEGIN
        INSERT INTO Appointments (DoctorID, PatientID, Date, Time, Status)
        SELECT DoctorID, PatientID, Date, Time, ISNULL(Status, 'Scheduled')
        FROM inserted;
    END
END;
GO