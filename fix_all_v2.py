#!/usr/bin/env python3
"""
Advanced corrupted text fixer for Arabic/Unicode content.
Handles mixed corrupted and correct text, and individual character fixes.
"""

import os
import glob
import re

def fix_string_content(content):
    """
    Fix corrupted text within a string by attempting to decode
    UTF-8 bytes that were misread as Latin-1.
    """
    try:
        # Try the basic fix: encode as latin1, decode as utf-8
        fixed = content.encode('latin1').decode('utf-8')
        
        # Check if the result looks valid (no more corrupted markers)
        if 'Ø' not in fixed and 'ù' not in fixed and 'Ù' not in fixed:
            return fixed
    except (UnicodeDecodeError, UnicodeEncodeError):
        pass
    
    return None

def fix_mixed_content(line):
    """
    Fix lines with mixed correct and corrupted Arabic text.
    These are trickier and need pattern-based approaches.
    """
    # Pattern for corrupted sequences: Ø/Ù followed by combining marks
    # Try to identify contiguous corrupted blocks
    
    # Find all corrupted blocks
    corrupted_blocks = re.finditer(r'[ØÙ][ÙˆØŠØ¨â€ä¸é"†ä¸ä¸ä¸ä¸¢ñ"€ñ"¡ø±ø§ø¬ø®ø¯øªøµø¼ùˆù'ù†ù„ù…ù„ù†ù‡]+', line)
    
    for block_match in reversed(list(corrupted_blocks)):
        corrupted_text = block_match.group(0)
        fixed_text = fix_string_content(corrupted_text)
        
        if fixed_text:
            line = line[:block_match.start()] + fixed_text + line[block_match.end():]
    
    return line

def fix_dart_file(file_path):
    """Fix a single Dart file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        original_lines = lines.copy()
        fixes = 0
        
        for i, line in enumerate(lines):
            # Look for corrupted patterns in quotes
            def replacer(match):
                nonlocal fixes
                quote = match.group(1)  # ' or "
                content = match.group(2)
                
                # Try to fix
                fixed = fix_string_content(content)
                
                if fixed and fixed != content:
                    fixes += 1
                    return f'{quote}{fixed}{quote}'
                
                # If that didn't work, try mixed content fix
                fixed_mixed = fix_mixed_content(content)
                if fixed_mixed != content:
                    fixes += 1
                    return f'{quote}{fixed_mixed}{quote}'
                
                return match.group(0)
            
            # Fix strings in this line
            lines[i] = re.sub(r"(['\"])([^'\"]*[ØÙ][^'\"]*)\1", replacer, lines[i])
        
        # Write if changed
        if lines != original_lines:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            return True, fixes
        
        return False, 0
        
    except Exception as e:
        print(f"  ⚠️  Error: {e}")
        return False, 0

def main():
    """Main entry point."""
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    print(f"🔧 Advanced fix for all corrupted text in {len(dart_files)} files\n")
    
    total_fixes = 0
    fixed_files = 0
    
    for file_path in dart_files:
        success, fixes = fix_dart_file(file_path)
        
        if success and fixes > 0:
            fixed_files += 1
            total_fixes += fixes
            print(f"✅ {file_path} ({fixes} fixes)")
    
    print(f"\n{'='*60}")
    print(f"📊 FINAL SUMMARY")
    print(f"{'='*60}")
    print(f"Files processed:  {len(dart_files)}")
    print(f"Files fixed:      {fixed_files}")
    print(f"Total fixes:      {total_fixes}")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()
