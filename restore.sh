#!/bin/bash

# Ensure correct usage
if [ $# -ne 1 ]; then
    echo "Usage: bash restore.sh <backup_file.tar.gz>"
    exit 1
fi

BACKUP_FILE=$1
SCHEMA_FILE="cockroach_schema.sql"
DATA_FILE="cockroach_data.sql"
TABLE_NAME="mock_data"  # Change this if your table name is different

# Database credentials
DB_URL="postgresql://abhinav:Vow-PSVyraRN20fJMG4X%2DA@testy-wallaby-8738.j77.aws-ap-south-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full"

# Extract the compressed backup
echo "Extracting backup file: $BACKUP_FILE..."
tar -xzf "$BACKUP_FILE"

if [ ! -f "$SCHEMA_FILE" ]; then
    echo "Error: Extracted schema file ($SCHEMA_FILE) not found!"
    exit 1
fi

echo "Dropping existing table: $TABLE_NAME (if it exists)..."
cockroach sql --url "$DB_URL" --execute "DROP TABLE IF EXISTS $TABLE_NAME CASCADE;"

echo "Restoring schema..."
cockroach sql --url "$DB_URL" --file="$SCHEMA_FILE"

if [ $? -ne 0 ]; then
    echo "Schema restore failed!"
    exit 1
fi

echo "Schema restored successfully!"

# Extract data restoration separately (if you have data insert SQL)
if [ -f "$DATA_FILE" ]; then
    echo "Restoring data..."
    cockroach sql --url "$DB_URL" --file="$DATA_FILE"
    
    if [ $? -eq 0 ]; then
        echo "Restore successful!"
    else
        echo "Restore failed!"
        exit 1
    fi
fi

# Clean up extracted files
rm -f "$SCHEMA_FILE" "$DATA_FILE"
echo "Cleanup complete!"
