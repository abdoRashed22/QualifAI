#!/usr/bin/env python3
"""
Comprehensive script to fix all corrupted UTF-8 text in lib/ folder.
The issue: Arabic/Unicode text was read as Latin-1, creating mojibake.
Solution: Encode back to Latin-1, then decode as UTF-8.
"""

import os
import glob
import re

def detect_and_fix_corrupted_file(file_path):
    """
    Detect corrupted encoding patterns and fix them.
    Returns: (success: bool, message: str, fixes_count: int)
    """
    try:
        # Read file with UTF-8
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        fixes = 0
        
        # Pattern: looks for sequences with corrupted Arabic characters
        # These are UTF-8 bytes incorrectly decoded as Latin-1
        corrupted_pattern = r'[ØÙÈ][\w¹-ÿ]{1,}'
        
        def fix_match(match):
            nonlocal fixes
            corrupted_str = match.group(0)
            try:
                # Try to fix: encode as Latin-1 (reverting the misinterpretation),
                # then decode as UTF-8 (the correct encoding)
                fixed = corrupted_str.encode('latin1').decode('utf-8')
                
                # Only count as fixed if it actually looks different and not mojibake
                if fixed != corrupted_str and not any(c in fixed for c in 'ØÙ'):
                    fixes += 1
                    return fixed
            except (UnicodeDecodeError, UnicodeEncodeError):
                pass
            
            return corrupted_str
        
        # Fix patterns in strings
        content = re.sub(corrupted_pattern, fix_match, content)
        
        # Also handle full corrupted strings in quotes
        corrupted_strings = re.findall(r"['\"]([^'\"]*[ØÙ][^'\"]*)['\"]", content)
        
        for corrupted_str in set(corrupted_strings):
            try:
                fixed = corrupted_str.encode('latin1').decode('utf-8')
                if fixed != corrupted_str:
                    # Escape quotes properly for replacement
                    content = content.replace(f"'{corrupted_str}'", f"'{fixed}'")
                    content = content.replace(f'"{corrupted_str}"', f'"{fixed}"')
                    fixes += 1
            except (UnicodeDecodeError, UnicodeEncodeError):
                pass
        
        # Write back if changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True, f"Fixed", fixes
        else:
            return False, "No changes", 0
            
    except Exception as e:
        return False, f"Error: {str(e)}", 0

def main():
    """Main entry point."""
    # Find all Dart files in lib/
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    print(f"🔍 Scanning {len(dart_files)} Dart files for corrupted text...\n")
    
    total_fixes = 0
    fixed_files = 0
    
    for file_path in dart_files:
        success, message, fixes = detect_and_fix_corrupted_file(file_path)
        
        if success:
            fixed_files += 1
            total_fixes += fixes
            print(f"✅ {file_path}")
            print(f"   → {message} ({fixes} strings)")
    
    print(f"\n{'='*60}")
    print(f"📊 SUMMARY")
    print(f"{'='*60}")
    print(f"Files scanned:    {len(dart_files)}")
    print(f"Files fixed:      {fixed_files}")
    print(f"Total fixes:      {total_fixes}")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
