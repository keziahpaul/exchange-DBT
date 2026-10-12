import os
def append_after_string(filename, new_line_to_append):
  """Appends a new line with {newline} after {anchor_line} in an SQL file.
  Args:
    filename: The name of the SQL file.
    new_line_to_append: The line to append (including the newline character).
  """
  with open(filename, 'r') as f:
    lines = f.readlines()
  modified_lines = []
  found = False

  anchor_line = "from source" # CHANGE THIS ANCHORING LINE

  for line in lines:
    modified_lines.append(line)
    if anchor_line in line:
      modified_lines.append(new_line_to_append)  # Appends new line
      found = True
  if not found:
    print(f"Warning: Anchoring Line: '{anchor_line}' not found in '{filename}'.")

  # Open again in write mode (truncates existing content)
  with open(filename, 'w') as f:
    f.writelines(modified_lines)

directory = 'helpers'  # Replace with your actual directory
for filename in os.listdir(directory):
  if filename.endswith('.sql'):
    full_path = os.path.join(directory, filename)
    added_line='    blahblah\n' # NEW LINE TO BE ADDED
    append_after_string(full_path, added_line)
    print(f"Successfully modified '{full_path}' - new line: {added_line} was added.")