-- Create a table with multiple fields to generate large data
CREATE TABLE large_dataset (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    bio TEXT
);

-- Insert a large number of rows with random data
INSERT INTO large_dataset (name, email, phone, address, bio)
SELECT 
    'User' || generate_series, 
    'user' || generate_series || '@example.com', 
    LPAD(floor(random() * 10000000000)::TEXT, 10, '0'),
    'Address ' || generate_series,
    repeat('Sample bio text. ', 50) -- Ensures each row has significant data
FROM generate_series(1, 1000000); -- Insert 1 million rows

-- This should generate a dataset of at least 500MB. You can increase the row count if needed.