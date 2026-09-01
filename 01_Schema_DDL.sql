CREATE DATABASE HospitalManagementSystem;
GO
USE HospitalManagementSystem;
GO
-- 1. Patients Table
CREATE TABLE Patients (
    PatientID INT IDENTITY(1,1) CONSTRAINT PK_Patients PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Gender NVARCHAR(10) NOT NULL CONSTRAINT CHK_Patients_Gender CHECK (Gender IN ('Male', 'Female', 'Other')),
    BirthDate DATE NOT NULL,
    Phone NVARCHAR(20) NULL,
    Address NVARCHAR(200) NULL
);
GO
-- 2. Doctor Table
CREATE TABLE Doctor (
    DoctorID INT IDENTITY(1,1) CONSTRAINT PK_Doctor PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Specialty NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(20) NULL
);
GO
-- 3. Room Table
CREATE TABLE Room (
    RoomID INT IDENTITY(1,1) CONSTRAINT PK_Room PRIMARY KEY,
    RoomType NVARCHAR(50) NOT NULL,
    Is_Available BIT NOT NULL CONSTRAINT DF_Room_IsAvailable DEFAULT 1
);
GO
-- 4. Medication Table
CREATE TABLE Medication (
    MedicationID INT IDENTITY(1,1) CONSTRAINT PK_Medication PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL CONSTRAINT CHK_Medication_Cost CHECK (Cost >= 0)
);
GO
-- 5. Appointments Table
CREATE TABLE Appointments (
    AppointmentID INT IDENTITY(1,1) CONSTRAINT PK_Appointments PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    [Date] DATE NOT NULL,
    [Time] TIME NOT NULL,
    [Status] NVARCHAR(50) NOT NULL CONSTRAINT DF_Appointments_Status DEFAULT 'Scheduled'
        CONSTRAINT CHK_Appointments_Status CHECK ([Status] IN ('Scheduled', 'Completed', 'Cancelled')),
    
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (PatientID) 
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT FK_Appointments_Doctor FOREIGN KEY (DoctorID) 
        REFERENCES Doctor(DoctorID) ON DELETE CASCADE
);
GO
-- 6. Prescriptions Table
CREATE TABLE Prescriptions (
    PrescriptionID INT IDENTITY(1,1) CONSTRAINT PK_Prescriptions PRIMARY KEY,
    AppointmentID INT NOT NULL,
    [Date] DATE NOT NULL CONSTRAINT DF_Prescriptions_Date DEFAULT GETDATE(),
    
    CONSTRAINT FK_Prescriptions_Appointments FOREIGN KEY (AppointmentID) 
        REFERENCES Appointments(AppointmentID) ON DELETE CASCADE
);
GO
-- 7. PrescriptionDetails Table (Junction Table: Prescription - Medication)

CREATE TABLE PrescriptionDetails (
    PrescriptionID INT NOT NULL,
    MedicationID INT NOT NULL,
    Dose NVARCHAR(100) NOT NULL,
    Frequency NVARCHAR(100) NOT NULL,
    
    CONSTRAINT PK_PrescriptionDetails PRIMARY KEY (PrescriptionID, MedicationID),
    CONSTRAINT FK_PrescriptionDetails_Prescriptions FOREIGN KEY (PrescriptionID) 
        REFERENCES Prescriptions(PrescriptionID) ON DELETE CASCADE,
    CONSTRAINT FK_PrescriptionDetails_Medication FOREIGN KEY (MedicationID) 
        REFERENCES Medication(MedicationID) ON DELETE CASCADE
);
GO
-- 8. Admissions Table

CREATE TABLE Admissions (
    AdmissionID INT IDENTITY(1,1) CONSTRAINT PK_Admissions PRIMARY KEY,
    PatientID INT NOT NULL,
    RoomID INT NOT NULL,
    AdmissionDate DATETIME NOT NULL CONSTRAINT DF_Admissions_AdmissionDate DEFAULT GETDATE(),
    DischargeDate DATETIME NULL,
    
    CONSTRAINT FK_Admissions_Patients FOREIGN KEY (PatientID) 
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT FK_Admissions_Room FOREIGN KEY (RoomID) 
        REFERENCES Room(RoomID),
    CONSTRAINT CHK_Admissions_Dates CHECK (DischargeDate IS NULL OR DischargeDate >= AdmissionDate)
);
GO

-- 9. EmergencyRoomTriage Table

CREATE TABLE EmergencyRoomTriage (
    TriageID INT IDENTITY(1,1) CONSTRAINT PK_EmergencyRoomTriage PRIMARY KEY,
    PatientID INT NOT NULL,
    TriageLevel INT NOT NULL CONSTRAINT CHK_ERTriage_Level CHECK (TriageLevel BETWEEN 1 AND 5),
    ArrivalTime DATETIME NOT NULL CONSTRAINT DF_ERTriage_ArrivalTime DEFAULT GETDATE(),
    [Status] NVARCHAR(50) NOT NULL CONSTRAINT DF_ERTriage_Status DEFAULT 'Waiting',
    AdmissionID INT NULL,
    
    CONSTRAINT FK_ERTriage_Patients FOREIGN KEY (PatientID) 
        REFERENCES Patients(PatientID) ON DELETE CASCADE,
    CONSTRAINT FK_ERTriage_Admissions FOREIGN KEY (AdmissionID) 
        REFERENCES Admissions(AdmissionID)
);
GO

-- 10. PatientBills Table

CREATE TABLE PatientBills (
    BillID INT IDENTITY(1,1) CONSTRAINT PK_PatientBills PRIMARY KEY,
    PatientID INT NOT NULL,
    AdmissionID INT NULL,
    [Date] DATETIME NOT NULL CONSTRAINT DF_PatientBills_Date DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL CONSTRAINT CHK_PatientBills_TotalAmount CHECK (TotalAmount >= 0),
    PaidStatus NVARCHAR(50) NOT NULL CONSTRAINT DF_PatientBills_PaidStatus DEFAULT 'Unpaid'
        CONSTRAINT CHK_PatientBills_PaidStatus CHECK (PaidStatus IN ('Paid', 'Unpaid', 'Pending')),
    
    CONSTRAINT FK_PatientBills_Patients FOREIGN KEY (PatientID) 
        REFERENCES Patients(PatientID),
    CONSTRAINT FK_PatientBills_Admissions FOREIGN KEY (AdmissionID) 
        REFERENCES Admissions(AdmissionID)
);
GO