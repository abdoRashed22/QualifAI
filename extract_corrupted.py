import glob
import re

dart_files = glob.glob('lib/**/*.dart', recursive=True)
corrupted_strings = {}

for file_path in dart_files:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # Find all strings with corrupted UTF-8 patterns
        matches = re.findall(r"['\"]([^'\"]*[ØÙØ†Ø¡Ø§Ø­Ø²Ø«Ø¬Ø¯Ø±Ø¸Ø¹Ø·Ø¶Ù‰Ù„Ù…Ù‡][^'\"]*)['\"]", content)
        for match in matches:
            if match not in corrupted_strings:
                try:
                    fixed = match.encode('latin1').decode('utf-8')
                    corrupted_strings[match] = fixed
                except:
                    pass
    except:
        pass

print(f'Found {len(corrupted_strings)} unique corrupted strings:\n')

mapping_code = "mapping = {\n"
for corrupted, fixed in sorted(corrupted_strings.items()):
    mapping_code += f"    {repr(corrupted)}: {repr(fixed)},\n"
mapping_code += "}\n"

# Write to a file
with open('corrupted_mapping.txt', 'w', encoding='utf-8') as f:
    f.write(mapping_code)

print(f"Mapping written to corrupted_mapping.txt")
print(f"\nFirst 20 entries:\n")
for i, (corrupted, fixed) in enumerate(list(sorted(corrupted_strings.items()))[:20], 1):
    print(f"{i}. {repr(corrupted)} -> {repr(fixed)}")
