# Step 3 - Add select * from renamed to complete model
# Used to add a select * from renamed line at the end of each model so it can be built in dbt.
# This should also look to be added to the generate_models.sh bash script, but was used as a workaround.
import os
import glob

# Get a list of all .sql files in the current directory
sql_files = glob.glob('*.sql')

# Loop through the list of files
for file_name in sql_files:
    # Open each file in append mode
    with open(file_name, 'a') as f:
        # Write the new line to the file
        f.write("\nselect * from renamed")