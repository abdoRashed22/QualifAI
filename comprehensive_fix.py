import os
import glob
import re

def find_corrupted_patterns(content):
    """Find all corrupted UTF-8 patterns in the content."""
    # Pattern for corrupted UTF-8: looks like Ø, Ù, etc mixed with normal text
    corrupted_pattern = r"[ØÙØ†Ø¡Ø§Ø­Ø²Ø«Ø¬Ø¯Ø±Ø¸Ø¹Ø·Ø¶Ù‰Ù†Ù„Ù…Ù„Ù†Ø£Ø·Ø¢Ø¥Ø© Ø•Ø•Ù†Ø«ØªØ¬Ø°Ø­Ù…ØºØ¼ÙˆÙŠØ«Ù‹]+"
    matches = re.findall(corrupted_pattern, content)
    return list(set(matches))

def fix_file_comprehensive(file_path):
    """Fix a file by detecting and correcting corrupted UTF-8 strings."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Find corrupted patterns
        patterns = find_corrupted_patterns(content)
        
        if patterns:
            # Try to fix by reading as Latin-1 and re-encoding as UTF-8
            try:
                # Re-open as Latin-1
                with open(file_path, 'r', encoding='latin-1') as f:
                    latin1_content = f.read()
                
                # Convert back to UTF-8
                fixed_content = latin1_content.encode('latin-1').decode('utf-8')
                
                # Write as UTF-8
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed_content)
                
                if fixed_content != original:
                    return True, f"Fixed {len(patterns)} corrupted patterns"
                else:
                    return False, "No actual changes"
            except Exception as e:
                return False, f"Conversion failed: {e}"
        else:
            return False, "No corrupted patterns found"
    except Exception as e:
        return False, f"File error: {e}"

# Find all Dart files
dart_files = glob.glob('lib/**/*.dart', recursive=True)

print(f"Deep scanning {len(dart_files)} files...\n")

fixed_count = 0
error_count = 0

for file_path in sorted(dart_files):
    success, message = fix_file_comprehensive(file_path)
    if success:
        fixed_count += 1
        print(f"✓ {file_path}: {message}")
    elif message != "No corrupted patterns found":
        print(f"~ {file_path}: {message}")

print(f"\n--- Summary ---")
print(f"Files Fixed: {fixed_count}")
print(f"Total: {len(dart_files)}")
