if [ $# -ne 2 ]; then
    echo "Usage: bash restore.sh <schema_file.sql> <data_file.csv>"
    exit 1
fi

SCHEMA_FILE=$1
DATA_FILE=$2

DB_URL="postgresql://abhinav:Vow-PSVyraRN20fJMG4X%2DA@testy-wallaby-8738.j77.aws-ap-south-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full"

echo "Restoring schema from $SCHEMA_FILE..."

cockroach sql --url "$DB_URL" --file="$SCHEMA_FILE"

if [ $? -ne 0 ]; then
    echo "Schema restore failed!"
    exit 1
fi

echo "Schema restored successfully!"

TABLE_NAME="mock_data"

echo "Deleting existing data from table: $TABLE_NAME..."
cockroach sql --url "$DB_URL" --execute "DELETE FROM $TABLE_NAME;"

echo "Generating SQL INSERT statements from CSV..."

python3 - <<EOF
import csv

TABLE_NAME = "$TABLE_NAME"  # Define table name

def csv_to_sql(input_csv, output_sql):
    with open(input_csv, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        rows = list(reader)
        columns = rows[0]

        insert_sql = ""
        for row in rows[1:]:
            values = []
            for v in row:
                v = v.replace("'", "''")  # Escape single quotes
                values.append(f"'{v}'")
            insert_sql += f"INSERT INTO {TABLE_NAME} ({', '.join(columns)}) VALUES ({', '.join(values)});\n"

        with open(output_sql, 'w', encoding='utf-8') as sqlfile:
            sqlfile.write(insert_sql)

csv_to_sql("$DATA_FILE", "restore_data.sql")
EOF

if [ ! -f "restore_data.sql" ]; then
    echo "Error: SQL file generation failed!"
    exit 1
fi

echo "Restoring data from generated SQL file..."
cockroach sql --url "$DB_URL" --file="restore_data.sql"

if [ $? -eq 0 ]; then
    echo "Restore successful!"
else
    echo "Restore failed!"
    exit 1
fi
