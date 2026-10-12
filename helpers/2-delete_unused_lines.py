# Step 2 - Delete unused lines
# Used to delete unused lines that are generated as part of the generate_models.sh bash script
# Ideally, these would be excluded in the generate_models.sh script, but this is a workaround
import os

directory = './'  # Replace with the actual directory path

# Iterate through all .sql files in the directory
for filename in os.listdir(directory):
    if filename.endswith('.sql'):
        filepath = os.path.join(directory, filename)
        
        # Read the contents of the file
        with open(filepath, 'r') as file:
            lines = file.readlines()
        
        # Delete the first 13 lines and the last 3 lines
        del lines[:13]
        del lines[-3:]
        
        # Write the modified contents back to the file
        with open(filepath, 'w') as file:
            file.writelines(lines)