-- Create Database
CREATE DATABASE TransportAndLogistics;

USE TransportAndLogistics;

-- Table: Customers
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(10),
    Country VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Shippers (Entities sending goods)
CREATE TABLE Shippers (
    ShipperID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(10),
    Country VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Consignees (Entities receiving goods)
CREATE TABLE Consignees (
    ConsigneeID INT AUTO_INCREMENT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    ContactPerson VARCHAR(100),
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    AddressLine1 VARCHAR(100),
    AddressLine2 VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    PostalCode VARCHAR(10),
    Country VARCHAR(50),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Vehicles (Updated with Fuel Consumption Fields)
CREATE TABLE Vehicles (
    VehicleID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleType ENUM('Truck', 'Van', 'Ship', 'Plane', 'Train') NOT NULL,
    RegistrationNumber VARCHAR(20) UNIQUE NOT NULL,
    Make VARCHAR(50),
    Model VARCHAR(50),
    Year INT,
    Capacity DECIMAL(10, 2), -- In tons or cubic meters
    Status ENUM('Available', 'In Transit', 'Maintenance') DEFAULT 'Available',
    FuelEfficiency DECIMAL(5, 2) NOT NULL DEFAULT 0, -- e.g., liters/100km or mpg
    TankCapacity DECIMAL(5, 2) NOT NULL DEFAULT 0, -- in liters or gallons
    TotalFuelConsumed DECIMAL(10, 2) NOT NULL DEFAULT 0, -- in liters or gallons
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Drivers
CREATE TABLE Drivers (
    DriverID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,
    HireDate DATE,
    Status ENUM('Active', 'Inactive') DEFAULT 'Active',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Routes
CREATE TABLE Routes (
    RouteID INT AUTO_INCREMENT PRIMARY KEY,
    OriginCity VARCHAR(50) NOT NULL,
    DestinationCity VARCHAR(50) NOT NULL,
    Distance DECIMAL(10, 2), -- In kilometers or miles
    EstimatedDuration TIME,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: Shipments
CREATE TABLE Shipments (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    ShipperID INT NOT NULL,
    ConsigneeID INT NOT NULL,
    RouteID INT NOT NULL,
    VehicleID INT,
    DriverID INT,
    ShipmentDate DATE NOT NULL,
    DeliveryDate DATE,
    Status ENUM('Pending', 'In Transit', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    Weight DECIMAL(10, 2), -- In kilograms
    Volume DECIMAL(10, 2), -- In cubic meters
    Description TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ShipperID) REFERENCES Shippers(ShipperID),
    FOREIGN KEY (ConsigneeID) REFERENCES Consignees(ConsigneeID),
    FOREIGN KEY (RouteID) REFERENCES Routes(RouteID),
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);

-- Table: Invoices
CREATE TABLE Invoices (
    InvoiceID INT AUTO_INCREMENT PRIMARY KEY,
    ShipmentID INT NOT NULL,
    InvoiceDate DATE NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    PaymentStatus ENUM('Unpaid', 'Paid') DEFAULT 'Unpaid',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ShipmentID) REFERENCES Shipments(ShipmentID)
);

-- Table: MaintenanceRecords
CREATE TABLE MaintenanceRecords (
    MaintenanceID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleID INT NOT NULL,
    MaintenanceDate DATE NOT NULL,
    Description TEXT,
    Cost DECIMAL(10, 2),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);

-- Table: FuelConsumptionRecords
CREATE TABLE FuelConsumptionRecords (
    ConsumptionID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleID INT NOT NULL,
    Date DATE NOT NULL,
    FuelFilled DECIMAL(10, 2) NOT NULL, -- in liters or gallons
    Cost DECIMAL(10, 2) NOT NULL, -- total cost of fuel filled
    OdometerReading DECIMAL(10, 2) NOT NULL, -- current odometer reading in km or miles
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID)
);

-- Trigger to Update TotalFuelConsumed in Vehicles Table
DELIMITER $$

CREATE TRIGGER AfterFuelConsumptionInsert
AFTER INSERT ON FuelConsumptionRecords
FOR EACH ROW
BEGIN
    UPDATE Vehicles
    SET TotalFuelConsumed = TotalFuelConsumed + NEW.FuelFilled
    WHERE VehicleID = NEW.VehicleID;
END$$

DELIMITER ;

-- Table: UserRoles
CREATE TABLE UserRoles (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

-- Table: Users
CREATE TABLE Users (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    RoleID INT NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    IsActive BOOLEAN DEFAULT TRUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES UserRoles(RoleID)
);

-- Sample Data Insertion for UserRoles
INSERT INTO UserRoles (RoleName) VALUES ('Admin');
INSERT INTO UserRoles (RoleName) VALUES ('Manager');
INSERT INTO UserRoles (RoleName) VALUES ('Dispatcher');
INSERT INTO UserRoles (RoleName) VALUES ('Driver');

-- Example: Inserting a sample user
INSERT INTO Users (RoleID, Username, PasswordHash, Email, IsActive)
VALUES (1, 'admin_user', 'hashed_password_for_admin', 'admin@example.com', TRUE);

-- Example Data Insertion for Vehicles
INSERT INTO Vehicles (VehicleType, RegistrationNumber, Make, Model, Year, Capacity, Status, FuelEfficiency, TankCapacity, TotalFuelConsumed)
VALUES 
('Truck', 'TRK12345', 'Volvo', 'FH16', 2020, 25.00, 'Available', 35.00, 400.00, 0.00),
('Van', 'VAN67890', 'Ford', 'Transit', 2019, 5.00, 'Available', 12.00, 80.00, 0.00),
('Ship', 'SHIP001', 'Maersk', 'E-Class', 2018, 15000.00, 'Available', 0.00, 0.00, 0.00);

-- Example Data Insertion for FuelConsumptionRecords
INSERT INTO FuelConsumptionRecords (VehicleID, Date, FuelFilled, Cost, OdometerReading)
VALUES 
(1, '2023-10-01', 200.00, 300.00, 10000.00),
(1, '2023-10-15', 150.00, 225.00, 11000.00),
(2, '2023-10-02', 50.00, 75.00, 5000.00);