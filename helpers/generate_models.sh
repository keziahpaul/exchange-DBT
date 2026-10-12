#!/bin/bash

# This script generates base model SQL files for each table in a specified source within a DBT project.
# It then compiles these models using DBT to extract the raw SQL, cleaning it for further use.
#
# Prerequisites:
# - DBT Cloud CLI must be installed and configured on your system.
# - This script should be placed in a folder named 'bash_scripts' within your DBT repository.
#
# Usage:
# 1. Create a folder named 'bash_scripts' inside your DBT repository if it doesn't already exist.
# 2. Place this script inside the 'bash_scripts' directory.
# 3. Navigate to the 'bash_scripts' directory in your terminal.
# 4. Run the script by executing: ./<script_name>.sh <source_name>
#    Replace <script_name> with the name of this script and <source_name> with the name of your source.
# 5. Wait for the script to finish processing all tables from the specified source.
# 6. Compiled SQL models will be available in the 'output' directory within 'bash_scripts'.


# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 source"
    exit 1
fi

# Assign the argument to 'source'
source="$1"

# Template of the content to generate for each table
template="{{ codegen.generate_base_model(
    source_name='%s',
    table_name='%s',
    materialized='table'
) }}"

# Ensure the generatedmodels directory exists
mkdir -p ../analyses/generatedmodels
mkdir output


# Use dbt ls to get a list of sources, filtering for the specific source, and extracting table names
tables=$(dbt ls --select source:"$source" --resource-type source | grep "source:" | awk -F'.' '{print $NF}')

# Check if tables were found
if [ -z "$tables" ]; then
    echo "No tables found for source: $source"
    exit 1
fi

# Loop through each table name extracted
echo "$tables" | while read -r table_name; do
    echo "Processing table: $table_name"
    
    # Define the output file for each table
    output_file="${table_name}.sql"

    # Generate the content with the current source and table
    content=$(printf "$template" "$source" "$table_name")
    # Write the content to the table-specific output file in the generatedmodels directory
    echo "$content" > "../analyses/generatedmodels/codegen_$output_file"
    
    echo "Generated model for table $table_name in $output_file"
done

for model_file in "../analyses/generatedmodels"/*; do
    echo "$model_file"
    # Extract the table name from the filename
    filename=$(basename "$model_file") # Gets 'codegen_<table_name>.sql'
    table_name=${filename#codegen_} # Removes the 'codegen_' prefix
    table_name=${table_name%.sql} # Removes the '.sql' suffix
    
    echo "Compiling model for table: $table_name"
    
    # Execute dbt compile for the specific table model
    dbt compile --select "codegen_$table_name" > vw_$table_name.sql
    sed -n '/Compiled node/,/Invocation has finished/p' temp_$table_name.sql | sed '1d;$d' > output/vw_$table_name.sql

done


echo "All tables processed."
