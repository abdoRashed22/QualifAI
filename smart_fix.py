import os
import glob
import re
from collections import defaultdict

def extract_all_corrupted_strings(content):
    """Extract all strings that look corrupted (contain Ø, Ù, etc patterns)."""
    # Find all strings that contain corrupted UTF-8 patterns
    pattern = r"['\"]([^'\"]*[ØÙØ†Ø¡Ø§Ø­Ø²Ø«Ø¬Ø¯Ø±Ø¸Ø¹Ø·Ø¶Ù‰Ù†Ù„Ù…Ù…Ù„Ù†Ø£Ø·Ø¢Ø¥Ø© Ø•Ø•Ù†Ø«ØªØ¬Ø°Ø­Ù…ØºØ¼ÙˆÙŠØ«Ù‹][^'\"]*)['\"]"
    matches = re.findall(pattern, content)
    return matches

def try_decode_corrupted_string(s):
    """Try to decode a corrupted string."""
    try:
        # Try Latin-1 to UTF-8
        decoded = s.encode('latin1').decode('utf-8')
        return decoded
    except:
        return None

def fix_file_with_detection(file_path):
    """Fix file by detecting all corrupted strings and fixing them."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Find all corrupted strings
        corrupted_strings = extract_all_corrupted_strings(content)
        
        if corrupted_strings:
            # Try to fix each one
            replacements = {}
            for corrupted in set(corrupted_strings):
                fixed = try_decode_corrupted_string(corrupted)
                if fixed and fixed != corrupted:
                    replacements[f"'{corrupted}'"] = f"'{fixed}'"
                    replacements[f'"{corrupted}"'] = f'"{fixed}"'
            
            # Apply all replacements
            for corrupted, fixed in replacements.items():
                content = content.replace(corrupted, fixed)
            
            # Write if changed
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                return True, f"Fixed {len(replacements)//2} strings"
            else:
                return False, "No changes after fix"
        else:
            return False, "No corrupted strings"
    except Exception as e:
        return False, str(e)

# Find all Dart files  
dart_files = glob.glob('lib/**/*.dart', recursive=True)

print(f"Smart fixing {len(dart_files)} files...\n")

fixed_count = 0
for file_path in sorted(dart_files):
    success, message = fix_file_with_detection(file_path)
    if success:
        fixed_count += 1
        print(f"✓ FIXED: {file_path}")
        print(f"  Message: {message}")

print(f"\n--- Summary ---")
print(f"Files Fixed: {fixed_count}/{len(dart_files)}")
