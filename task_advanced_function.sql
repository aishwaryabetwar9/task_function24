CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    remarks TEXT
);
select * from patients;
select * from appointments;

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT,
    doctor_name VARCHAR(100),
    department VARCHAR(50),
    visit_date DATE,
    fee NUMERIC(10,2),
    status VARCHAR(20),
    notes TEXT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

CREATE OR REPLACE FUNCTION validate_patient(
    p_name VARCHAR,
    p_age INT,
    p_gender VARCHAR,
    p_phone VARCHAR,
    p_address TEXT,
    p_remarks TEXT
)
RETURNS TEXT AS $$
BEGIN
    IF p_name IS NULL OR LENGTH(p_name) < 3 THEN
        RETURN 'Name must be at least 3 characters.';
    END IF;

    IF p_age < 0 OR p_age > 120 THEN
        RETURN 'Age must be between 0 and 120.';
    END IF;

    IF p_gender NOT IN ('Male', 'Female', 'Other') THEN
        RETURN 'Gender must be Male, Female, or Other.';
    END IF;

    IF LENGTH(p_phone) < 10 THEN
        RETURN 'Phone number must be at least 10 digits.';
    END IF;

    IF LENGTH(p_address) < 5 THEN
        RETURN 'Address too short.';
    END IF;

    IF LENGTH(p_remarks) < 3 THEN
        RETURN 'Remarks must be at least 3 characters.';
    END IF;

    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_appointment(
    p_patient_id INT,
    p_doctor_name VARCHAR,
    p_department VARCHAR,
    p_visit_date DATE,
    p_fee NUMERIC,
    p_status VARCHAR,
    p_notes TEXT
)
RETURNS TEXT AS $$
BEGIN
    IF p_patient_id IS NULL OR p_patient_id <= 0 THEN
        RETURN 'Invalid patient ID.';
    END IF;

    IF LENGTH(p_doctor_name) < 3 THEN
        RETURN 'Doctor name too short.';
    END IF;

    IF LENGTH(p_department) < 3 THEN
        RETURN 'Department name too short.';
    END IF;

    IF p_visit_date IS NULL OR p_visit_date < CURRENT_DATE THEN
        RETURN 'Visit date cannot be before today.';
    END IF;

    IF p_fee <= 0 THEN
        RETURN 'Fee must be greater than zero.';
    END IF;

    IF p_status NOT IN ('BOOKED','CANCELLED','COMPLETED') THEN
        RETURN 'Invalid appointment status.';
    END IF;

    RETURN 'OK';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_patient(
    p_name VARCHAR,
    p_age INT,
    p_gender VARCHAR,
    p_phone VARCHAR,
    p_address TEXT,
    p_remarks TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_check TEXT;
BEGIN
    v_check := validate_patient(p_name, p_age, p_gender, p_phone, p_address, p_remarks);

    IF v_check <> 'OK' THEN
        RETURN v_check;
    END IF;

    INSERT INTO patients(full_name, age, gender, phone, address, remarks)
    VALUES (p_name, p_age, p_gender, p_phone, p_address, p_remarks);

    RETURN 'Patient inserted successfully!';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION insert_appointment(
    p_patient_id INT,
    p_doctor_name VARCHAR,
    p_department VARCHAR,
    p_visit_date DATE,
    p_fee NUMERIC,
    p_status VARCHAR,
    p_notes TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_check TEXT;
BEGIN
    v_check := validate_appointment(p_patient_id, p_doctor_name, p_department, p_visit_date, p_fee, p_status, p_notes);

    IF v_check <> 'OK' THEN
        RETURN v_check;
    END IF;

    INSERT INTO appointments(patient_id, doctor_name, department, visit_date, fee, status, notes)
    VALUES (p_patient_id, p_doctor_name, p_department, p_visit_date, p_fee, p_status, p_notes);

    RETURN 'Appointment inserted successfully!';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION hospital_summary()
RETURNS TABLE(
    total_patients BIGINT,
    total_appointments BIGINT,
    total_fee_collected NUMERIC,
    todays_appointments BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT p.patient_id),
        COUNT(a.appointment_id),
        SUM(a.fee),
        COUNT(a2.appointment_id)
    FROM patients p
    LEFT JOIN appointments a
        ON a.patient_id = p.patient_id
    LEFT JOIN appointments a2
        ON a2.patient_id = p.patient_id
       AND a2.visit_date = CURRENT_DATE;
END;
$$;

SELECT * FROM hospital_summary();

select * from appointments

SELECT insert_appointment(1,'Dr. Mehta','Cardiology',CURRENT_DATE + 1,500.00,'BOOKED','First visit');


INSERT INTO patients (full_name, age, gender, phone, address, remarks)
VALUES
('Rahul Sharma', 28, 'Male', '9876543210', 'Delhi, India', 'Regular checkup'),
('Priya Verma', 34, 'Female', '9891122334', 'Mumbai, India', 'Follow-up appointment'),
('Amit Kumar', 42, 'Male', '9877001122', 'Kolkata, India', 'Diabetes management'),
('Sara Khan', 25, 'Female', '9988776655', 'Bangalore, India', 'General checkup'),
('Rohan Malhotra', 31, 'Male', '9001122334', 'Chandigarh, India', 'Dental cleaning'),
('Neha Singh', 29, 'Female', '9876654321', 'Pune, India', 'Yearly physical check'),
('Vikas Thakur', 38, 'Male', '9811122244', 'Jaipur, India', 'Blood pressure monitoring'),
('Ritu Kapoor', 47, 'Female', '9090909090', 'Hyderabad, India', 'Thyroid consultation'),
('Sandeep Joshi', 55, 'Male', '9887766554', 'Ahmedabad, India', 'Heart patient'),
('Meena Nair', 63, 'Female', '9822334455', 'Kochi, India', 'Follow-up visit'),
('Kabir Khan', 33, 'Male', '9870011223', 'Lucknow, India', 'Orthopedic consultation'),
('Ananya Bose', 22, 'Female', '9933445566', 'Kolkata, India', 'General fever'),
('Ravi Patel', 40, 'Male', '9875566778', 'Surat, India', 'Back pain'),
('Simran Kaur', 26, 'Female', '9876655000', 'Amritsar, India', 'Eye checkup'),
('Arjun Reddy', 45, 'Male', '9008899776', 'Hyderabad, India', 'Surgery follow-up');

INSERT INTO appointments (patient_id, doctor_name, department, visit_date, fee, status, notes)
VALUES
(1, 'Dr. Mehta', 'Cardiology', CURRENT_DATE + 1, 500.00, 'BOOKED', 'Initial consultation'),
(2, 'Dr. Sharma', 'Dermatology', CURRENT_DATE + 3, 700.00, 'BOOKED', 'Skin allergy check'),
(3, 'Dr. Banerjee', 'Endocrinology', CURRENT_DATE + 2, 650.00, 'BOOKED', 'Diabetes follow-up'),
(4, 'Dr. Iqbal', 'General Medicine', CURRENT_DATE + 1, 300.00, 'BOOKED', 'Routine checkup'),
(5, 'Dr. Malhotra', 'Dentistry', CURRENT_DATE + 5, 450.00, 'BOOKED', 'Teeth cleaning'),
(6, 'Dr. Joshi', 'General Medicine', CURRENT_DATE + 2, 350.00, 'BOOKED', 'Routine check'),
(7, 'Dr. Anand', 'Cardiology', CURRENT_DATE + 1, 800.00, 'BOOKED', 'Heart check-up'),
(8, 'Dr. Mishra', 'Endocrinology', CURRENT_DATE + 4, 600.00, 'BOOKED', 'Thyroid levels review'),
(9, 'Dr. Chauhan', 'Neurology', CURRENT_DATE + 3, 900.00, 'BOOKED', 'Headache examination'),
(10, 'Dr. Menon', 'Geriatrics', CURRENT_DATE + 1, 500.00, 'BOOKED', 'Senior health check'),
(11, 'Dr. Kapoor', 'Orthopedics', CURRENT_DATE + 5, 750.00, 'BOOKED', 'Knee pain diagnosis'),
(12, 'Dr. Rao', 'ENT', CURRENT_DATE + 2, 400.00, 'BOOKED', 'Ear infection'),
(13, 'Dr. Gill', 'Ophthalmology', CURRENT_DATE + 3, 450.00, 'BOOKED', 'Eye irritation'),
(14, 'Dr. Prakash', 'Physiotherapy', CURRENT_DATE + 6, 350.00, 'BOOKED', 'Back strengthening therapy'),
(15, 'Dr. Fernandes', 'Surgery', CURRENT_DATE + 7, 1200.00, 'BOOKED', 'Post-op consultation');

select insert_patient(
    'Anita Sharma',
    30,
    'Alien',    
    '9876543210',
    'Pune, India',
    'Healthy'
);
SELECT insert_patient(
    'Mohit Kumar',
    40,
    'Male',
    '123',      
    'Mumbai, India',
    'Routine'
);
SELECT insert_patient(
    'Suresh Patel',
    50,
    'Male',
    '9876504321',
    'Ahmedabad, India',
    'No'       
);
SELECT insert_appointment(
    -1,            
    'Dr. Mehta',
    'Cardiology',
    CURRENT_DATE + 1,
    500,
    'BOOKED',
    'Note'
);
SELECT insert_appointment(
    1,
    'Dr. Sharma',
    'ER',         
    CURRENT_DATE + 3,
    300,
    'BOOKED',
    'Emergency case'
);
SELECT insert_patient(
    'Rahul Sharma',    
    28,                
    'Male',            
    '9876543210',      
    'Delhi, India',    
    'Regular checkup'  
);
SELECT insert_patient(
    'Ra',            
    -5,                
    'Unknown',         
    '123',             
    'A',           
    'No'             
);

select * from appointments

SELECT insert_appointment(
    1,                  
    'Dr. Mehta',       
    'Cardiology',      
    CURRENT_DATE + 1,  
    500.00,             
    'BOOKED',           
    'First visit'      
);

SELECT validate_patient('Ra', 25, 'Male', '9876543210', 'Delhi, India', 'Okay');
SELECT validate_patient('John Doe', -5, 'Male', '9876543210', 'Mumbai, India', 'Test');
SELECT validate_patient('Mohit Kumar', 40, 'Male', '123', 'Delhi, India', 'Remarks');
SELECT validate_appointment(-1, 'Dr. Mehta', 'Cardiology', CURRENT_DATE + 1, 500, 'BOOKED', 'Note');
SELECT validate_appointment(1, 'Dr. Sharma', 'ER', CURRENT_DATE + 3, 300, 'BOOKED', 'Emergency');
SELECT validate_appointment(1, 'Dr. Mehta', 'Cardiology', CURRENT_DATE - 1, 500, 'BOOKED', 'Check');
SELECT validate_patient('Samir Khan',40,'Other','9877001122','Kolkata, India','General health evaluation');
SELECT validate_patient('Arjun Reddy',45,'Male','9008899776','Hyderabad, India','Post-surgery follow-up');
SELECT validate_appointment(1,'Dr. Mehta','Cardiology',CURRENT_DATE + 1,500.00,'BOOKED','Initial consultation');
SELECT validate_appointment(3,'Dr. Banerjee','Endocrinology',CURRENT_DATE + 3,650.00,'BOOKED','Diabetes check');



























