import os

# Define the directory path where the .sql files are located
directory_path = 'models/data_services/projects/historical'
# directory_path = 'models/curate/temp'

# Loop through each file in the directory
for filename in os.listdir(directory_path):
    # Check if the file is a .sql file
    if filename.endswith('.sql'):
        # Split the filename into name and extension
        name, extension = os.path.splitext(filename)

        # Check if 'vw' is in the filename
        if 'vw' in name:
            # Insert '_cur' after 'vw'
            new_name = name.replace('vw_cur_', 'vw_') + extension
            # new_name = name + '_hist' + extension # append _hist to file name

            # Construct the full old and new file paths
            old_file_path = os.path.join(directory_path, filename)
            new_file_path = os.path.join(directory_path, new_name)
            # Rename the file
            os.rename(old_file_path, new_file_path)
            print(f'Renamed "{filename}" to "{new_name}"')