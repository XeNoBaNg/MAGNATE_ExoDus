# Cockroach DB Backup and Restore

This project provides scripts to backup and restore data in a Cockroach DB instance. The `mock_data` table is used as an example. The scripts facilitate seamless backup, including schema and data, and restoration of the database.

## Prerequisites

### 1. Install CockroachDB
Before you can use the scripts, you need to install CockroachDB on your machine. You can follow the official documentation to install CockroachDB on your machine:  
[CockroachDB Installation Guide](https://www.cockroachlabs.com/docs/v22.1/install-cockroachdb)

### 2. Python (Required for Backup Script)
The backup process requires Python 3 to convert the data into SQL format.  
If you don't have Python installed, follow the instructions here:  
[Python Installation Guide](https://www.python.org/downloads/)

#### If Python is not found:
If you get a "Python not found" error when running the backup script, ensure that Python and its `Scripts` folder are added to the system's environment variables.

1. **Find the Python Installation Path**:
   - For Windows, the default location is usually something like:
     - `C:\Users\<YourUser>\AppData\Local\Programs\Python\Python<version>\`
     - For `Scripts` folder: `C:\Users\<YourUser>\AppData\Local\Programs\Python\Python<version>\Scripts\`
   
2. **Add Python and `Scripts` folder to PATH**:
   - Right-click on "This PC" > Properties > Advanced system settings > Environment Variables.
   - Under "System variables", find `Path` and click `Edit`.
   - Add the path to Python and the `Scripts` folder to the list of paths.
   - Restart your terminal for the changes to take effect.

### 3. Install Dependencies

This project requires the `cockroach` command-line tool. If you haven't installed it, you can follow the instructions here:  
[CockroachDB CLI Setup](https://www.cockroachlabs.com/docs/v22.1/cockroach-commands/)

Additionally, the backup script uses Python’s `csv` module to convert data into SQL format, which is part of the Python standard library, so no extra installation is required.

## Setup Cockroach DB Connection

1. **Obtain Database URL**:  
   You will need the connection URL for your CockroachDB instance. The format for the URL is:

   ```
   cockroach sql --url "postgresql://<username>:<password>@<host>:<port>/<database>"
   ```

2. **Configure your DB URL**:  
   Replace the `<ENTER_DB_CONNECTION_URL>` placeholder in the script with your actual CockroachDB connection URL.

## Using the Scripts

### 1. Backup Database

To backup your `mock_data` table, run the following command in the terminal:

```bash
bash backup.sh
```

This will:
- Create a backup file (`backup.tar.gz`) containing the schema and data of the `mock_data` table.
- The backup includes both the schema (`cockroach_schema.sql`) and data (`cockroach_data.csv`).

### 2. Restore Database

If you need to restore the database (e.g., if the `mock_data` table is deleted), run the following command:

```bash
bash restore.sh backup.tar.gz
```

This will:
- Extract the schema and data from the `backup.tar.gz` file.
- Drop the existing `mock_data` table and restore the schema and data from the backup.

### 3. Troubleshooting: Python Not Found

If you encounter an error saying Python is not found, you might need to add the Python installation directory and its `Scripts` directory to your system's environment path.

1. **Find the Python installation directory and Scripts directory**:
   The default installation paths for Python on Windows are usually:
   - `C:\Users\<YourUser>\AppData\Local\Programs\Python\Python<version>\`
   - The `Scripts` folder is usually located in the same directory: `C:\Users\<YourUser>\AppData\Local\Programs\Python\Python<version>\Scripts\`

2. **Add to the system's PATH**:
   - Go to the environment variables (right-click This PC > Properties > Advanced system settings > Environment Variables).
   - Add the Python and `Scripts` folder paths to the `Path` variable in the system environment variables.
   - Restart the terminal for the changes to take effect.
Certainly! Here's an additional section to guide users on how to run the `backup.sh` script biweekly using Task Scheduler on Windows.

---

### 4. Schedule Backup Using Task Scheduler (Windows)

You can set up Task Scheduler to automatically run the `backup.sh` script every two weeks to ensure your database is regularly backed up. Follow the steps below to schedule the script.

#### Step-by-Step Guide to Setting Up Task Scheduler:

1. **Open Task Scheduler**:
   - Press `Win + R` to open the Run dialog.
   - Type `taskschd.msc` and press Enter to open Task Scheduler.

2. **Create a New Task**:
   - In Task Scheduler, click on **"Create Task"** from the right-hand panel.
   - In the **General** tab:
     - **Name**: Give your task a descriptive name like `CockroachDB Backup`.
     - **Description**: (Optional) Add a description, like "Runs the backup.sh script every two weeks to back up the CockroachDB database."

3. **Set the Trigger**:
   - Switch to the **Triggers** tab.
   - Click **New** to create a new trigger.
   - In the **New Trigger** window:
     - Set the **Begin the task** dropdown to **"On a schedule"**.
     - Choose **Weekly** and set it to run **every 2 weeks** on your preferred day and time (e.g., every Monday at 2:00 PM).
   - Click **OK** to save the trigger.

4. **Set the Action**:
   - Switch to the **Actions** tab.
   - Click **New** to create a new action.
   - In the **New Action** window:
     - **Action**: Choose **Start a Program**.
     - **Program/script**: Browse and select `bash.exe`. If you have Git Bash installed, the path will typically be:
       ```
       C:\Program Files\Git\bin\bash.exe
       ```
     - **Add arguments**: Add the path to your `backup.sh` script. For example:
       ```
       "C:\path\to\your\project\backup.sh"
       ```
     - **Start in**: Specify the folder where the `backup.sh` script is located (e.g., `C:\path\to\your\project`).

   - Click **OK** to save the action.

5. **Finish and Test**:
   - Review the settings in the **Conditions** and **Settings** tabs, and adjust them as needed (you can leave them as default).
   - Click **OK** to create the task.
   - To test if the task works, right-click the task in Task Scheduler and select **Run**. If everything is set up correctly, the script will run and create the backup.

#### Verify the Scheduled Task:
- Check the backup location after the scheduled time to verify that the backup file has been created.
- You can also check Task Scheduler’s **History** tab to review the task execution logs.

---

## File Descriptions

- **backup.sh**: This script will backup the `mock_data` table from your CockroachDB and create a compressed `.tar.gz` file containing the schema and data in SQL format.
- **restore.sh**: This script restores the database by extracting the schema and data from the backup file and recreating the `mock_data` table.
- **Python script in backup.sh**: The Python code inside the `backup.sh` file converts the `mock_data` table's data (exported as CSV) into SQL `INSERT` statements.
