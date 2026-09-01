-- ===============================================================================
-- Script Name: 02_Seed_Data_DML.sql
-- Description: Sample Data Insertion for Testing and Demonstration
-- System: Hospital & Clinical Management System
-- Database Engine: SQL Server Management Studio (SSMS)
-- ===============================================================================

USE HospitalManagementSystem;
GO

-- ===============================================================================
-- 1. Seed Patients
-- ===============================================================================
INSERT INTO Patients (Name, Gender, BirthDate, Phone, Address) VALUES
('Ahmed Mahmoud Ali', 'Male', '1985-04-12', '01012345678', 'Cairo - Nasr City'),
('Mariam Mohamed Ibrahim', 'Female', '1992-08-25', '01123456789', 'Sharqia - Zagazig'),
('Omar Khaled Hassanain', 'Male', '1978-11-03', '01234567890', 'Giza - Dokki'),
('Sara Youssef Ahmed', 'Female', '2001-02-15', '01545678901', 'Cairo - Maadi'),
('Mahmoud Moustafa Kamal', 'Male', '1965-06-30', '01098765432', 'Alexandria - Smouha');
GO
-- ===============================================================================
-- 2. Seed Doctor
-- ===============================================================================
INSERT INTO Doctor (Name, Specialty, Phone) VALUES
('Dr. Hazem Abdel Aziz', 'Cardiology', '01001112233'),
('Dr. Rania Nabil', 'Pediatrics', '01112223344'),
('Dr. Tarek El Sherif', 'Orthopedics', '01223334455'),
('Dr. Shaimaa Farouk', 'Neurology', '01554443322');
GO

-- ===============================================================================
-- 3. Seed Room
-- ===============================================================================
INSERT INTO Room (RoomType, Is_Available) VALUES
('Single ICU', 0),      -- RoomID: 1 (Occupied)
('Double General', 1),  -- RoomID: 2 (Available)
('VIP Suite', 0),       -- RoomID: 3 (Occupied)
('Single General', 1),  -- RoomID: 4 (Available)
('Double General', 1);  -- RoomID: 5 (Available)
GO

-- ===============================================================================
-- 4. Seed Medication
-- ===============================================================================
INSERT INTO Medication (Name, Cost) VALUES
('Panadol Extra 500mg', 35.00),
('Augmentin 1g', 110.00),
('Concor 5mg', 85.50),
('Cataflam 50mg', 45.00),
('Omeprazole 20mg', 60.00);
GO

-- ===============================================================================
-- 5. Seed Appointments
-- ===============================================================================
INSERT INTO Appointments (PatientID, DoctorID, [Date], [Time], [Status]) VALUES
(1, 1, '2026-08-20', '09:30:00', 'Completed'),
(2, 2, '2026-08-22', '11:00:00', 'Completed'),
(3, 3, '2026-08-25', '14:00:00', 'Completed'),
(4, 1, '2026-08-28', '10:00:00', 'Scheduled'),
(5, 4, '2026-08-30', '13:30:00', 'Scheduled');
GO

-- ===============================================================================
-- 6. Seed Prescriptions
-- ===============================================================================
INSERT INTO Prescriptions (AppointmentID, [Date]) VALUES
(1, '2026-08-20'),
(2, '2026-08-22'),
(3, '2026-08-25');
GO

-- ===============================================================================
-- 7. Seed PrescriptionDetails
-- ===============================================================================
INSERT INTO PrescriptionDetails (PrescriptionID, MedicationID, Dose, Frequency) VALUES
(1, 1, '1 Tablet', 'Every 8 Hours'),
(1, 3, '1/2 Tablet', 'Once Daily in Morning'),
(2, 2, '1 Tablet', 'Every 12 Hours after meals'),
(3, 4, '1 Tablet', 'As needed for pain'),
(3, 5, '1 Capsule', 'Before Breakfast');
GO

-- ===============================================================================
-- 8. Seed Admissions
-- ===============================================================================
INSERT INTO Admissions (PatientID, RoomID, AdmissionDate, DischargeDate) VALUES
(1, 1, '2026-08-15 08:00:00', NULL),                  -- Currently Admitted in ICU
(3, 3, '2026-08-10 14:30:00', '2026-08-18 12:00:00'), -- Discharged
(5, 3, '2026-08-29 20:00:00', NULL);                  -- Currently Admitted in VIP
GO

-- ===============================================================================
-- 9. Seed EmergencyRoomTriage
-- ===============================================================================
INSERT INTO EmergencyRoomTriage (PatientID, TriageLevel, ArrivalTime, [Status], AdmissionID) VALUES
(1, 1, '2026-08-15 07:15:00', 'Admitted', 1),
(2, 4, '2026-08-28 18:20:00', 'Discharged', NULL),
(5, 2, '2026-08-29 19:10:00', 'Admitted', 3),
(4, 3, '2026-08-30 15:45:00', 'Waiting', NULL);
GO

-- ===============================================================================
-- 10. Seed PatientBills
-- ===============================================================================
INSERT INTO PatientBills (PatientID, AdmissionID, [Date], TotalAmount, PaidStatus) VALUES
(3, 2, '2026-08-18 12:30:00', 4500.00, 'Paid'),
(1, 1, '2026-08-21 10:00:00', 1200.00, 'Pending'),
(2, NULL, '2026-08-28 19:00:00', 350.00, 'Paid'),
(5, 3, '2026-08-30 09:00:00', 2800.00, 'Unpaid');
GO