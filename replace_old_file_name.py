import csv

def read_mapping_file(mapping_file_path):
    mapping = {}
    with open(mapping_file_path, mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            mapping[row['old']] = row['new']
    return mapping

def replace_names_in_config(mapping, config_file_path, output_file_path):
    matches = []
    non_matches = []
    
    with open(config_file_path, mode='r') as file:
        config_lines = file.readlines()

    with open(output_file_path, mode='w') as file:
        for line in config_lines:
            original_line = line
            for old_name, new_name in mapping.items():
                if old_name in line:
                    line = line.replace(old_name, new_name)
                    matches.append((old_name, new_name))
            if line == original_line:
                non_matches.append(original_line.strip())
            file.write(line)
    
    return matches, non_matches

def main():
    mapping_file_path = 'mapping.csv'
    config_file_path = 'config.txt'
    output_file_path = 'updated_config.txt'

    # Read the mapping file
    mapping = read_mapping_file(mapping_file_path)

    # Replace old names with new names in the config file
    matches, non_matches = replace_names_in_config(mapping, config_file_path, output_file_path)

    # Display results
    print("Matched Records:")
    for old_name, new_name in matches:
        print(f"{old_name} -> {new_name}")

    print("\nNon-Matched Lines:")
    for line in non_matches:
        print(line)

if __name__ == "__main__":
    main()
