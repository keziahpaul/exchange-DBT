# Step 1 - Rename Fivetran fields
# Used to rename the default Fivetran audit columns with the appropriate names as per our ONEData design
import os
import re

def replace_string_in_files(directory, search_string, replace_string):
    for filename in os.listdir(directory):
        if filename.endswith(".sql"):
            file_path = os.path.join(directory, filename)
            with open(file_path, "r") as file:
                content = file.read()
            
            # Perform the string replacement
            new_content = re.sub(search_string, replace_string, content)
            
            with open(file_path, "w") as file:
                file.write(new_content)

directory = "./"
search_string = r"\s+_fivetran_synced,\n\s+_fivetran_start,\n\s+_fivetran_end,\n\s+_fivetran_active"
replace_string = "\n        _fivetran_start as effective_from,\n        _fivetran_end as effective_to,\n        _fivetran_start as inserted_at,\n        _fivetran_end as updated_at"

replace_string_in_files(directory, search_string, replace_string)
