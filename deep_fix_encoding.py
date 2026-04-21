import os
import glob
import re

def try_fix_encoding(content):
    """Try multiple encoding fixes."""
    # First, try the standard Latin-1 to UTF-8 conversion
    try:
        fixed = content.encode('latin1').decode('utf-8')
        # Check if it looks better
        if 'ØªÙ…' not in fixed:
            return fixed
    except:
        pass
    
    # If still broken, try to identify and fix corrupted sequences
    # Pattern: corrupted UTF-8 bytes that look like ØªÙ…
    try:
        # Try decoding assuming the corrupted text is UTF-8 bytes interpreted as Latin-1
        # and convert back properly
        result = content
        # Replace known corrupted patterns with correct Arabic
        corrupted_patterns = {
            'ØªÙ… Ø±ÙØ¹ Ø§Ù„Ù…Ù„Ù Ø¨Ù†Ø¬Ø§Ø­': 'تم رفع الملف بنجاح',
            'Ø±ÙØ¹ Ù…Ù„Ù Ø¬Ø¯ÙŠØ¯': 'رفع ملف جديد',
            'Ø¬Ø§Ø±ÙŠ Ø§Ù„Ø±ÙØ¹': 'جاري الرفع',
        }
        
        for corrupted, correct in corrupted_patterns.items():
            result = result.replace(corrupted, correct)
        
        return result
    except:
        return content

def fix_dart_file(file_path):
    """Fix encoding in Dart file."""
    try:
        # Try reading as UTF-8 first
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Try to fix the encoding
        fixed_content = try_fix_encoding(content)
        
        # Write back
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(fixed_content)
        
        return True, "Fixed"
    except Exception as e:
        return False, str(e)

# Find all Dart files
dart_files = glob.glob('lib/**/*.dart', recursive=True)

print(f"Found {len(dart_files)} Dart files...\n")

fixed_count = 0
error_count = 0

for file_path in sorted(dart_files):
    success, message = fix_dart_file(file_path)
    if success:
        fixed_count += 1
        print(f"✓ {file_path}")
    else:
        error_count += 1
        print(f"✗ {file_path}: {message}")

print(f"\n--- Summary ---")
print(f"Fixed: {fixed_count} files")
print(f"Errors: {error_count} files")
print(f"Total: {len(dart_files)} files")
