#!/bin/bash

DB_URL="postgresql://abhinav:Vow-PSVyraRN20fJMG4X%2DA@testy-wallaby-8738.j77.aws-ap-south-1.cockroachlabs.cloud:26257/defaultdb?sslmode=verify-full"

SCHEMA_FILE="cockroach_schema.sql"
DATA_FILE="cockroach_data.csv"
COMPRESSED_FILE="backup.tar.gz"

cockroach sql --url "$DB_URL" --execute "SELECT * FROM mock_data;" --format=csv > "$DATA_FILE"

python3 - <<EOF
import csv

def csv_to_sql(input_csv, output_sql):
    with open(input_csv, newline='', encoding='utf-8') as csvfile:
        reader = csv.reader(csvfile)
        rows = list(reader)
        columns = rows[0]
        
        create_table_sql = "CREATE TABLE MOCK_DATA (\n"
        for col in columns:
            if col == 'id':
                create_table_sql += f"\t{col} INT,\n"
            else:
                create_table_sql += f"\t{col} VARCHAR(50),\n"
        create_table_sql = create_table_sql.rstrip(',\n') + "\n);\n"

        insert_sql = ""
        for row in rows[1:]:
            values = []
            for v in row:
                v = v.replace("'", "''")  # Escape single quotes
                values.append(f"'{v}'")
            insert_sql += f"INSERT INTO MOCK_DATA ({', '.join(columns)}) VALUES ({', '.join(values)});\n"

        with open(output_sql, 'w', encoding='utf-8') as sqlfile:
            sqlfile.write(create_table_sql)
            sqlfile.write(insert_sql)

csv_to_sql("$DATA_FILE", "$SCHEMA_FILE")
EOF

if [ $? -eq 0 ]; then
    echo "Backup successful: $SCHEMA_FILE & $DATA_FILE"
    tar -czf "$COMPRESSED_FILE" "$SCHEMA_FILE"
    rm "$SCHEMA_FILE"
    rm "$DATA_FILE"
    echo "SQL file compressed: $COMPRESSED_FILE"
else
    echo "Backup failed!"
    exit 1
fi
