#!/usr/bin/env python3
"""
Final comprehensive fix for corrupted Arabic text.
Uses direct pattern matching and encoding tricks.
"""

import os
import glob
import re

# Build a comprehensive mapping by trying to decode all corrupted patterns
def get_fix_mapping():
    """Generate all possible corrupted->fixed mappings."""
    mapping = {}
    
    # Known corrupted patterns from the codebase
    corrupted_samples = [
        'ÙƒÙŠÙˆÙ„ÙŠÙ',  # should be كيوليف
        'Ù†Ø¸Ø§Ù…',      # should be نظام
        'Ù„Ø§ ÙŠÙˆØ¬Ø¯',  # should be لا يوجد
        'Ø§ØªØµØ§Ù„',    # should be اتصال
        'Ø®Ø·Ø£',        # should be خطأ
        'Ù…Ø±Ø­Ø¨Ø§',    # should be مرحبا
        'Ø§Ø³Ù…',        # should be اسم
        'Ù„Ù„Ù…',        # should be للم
        'Ø±ÙØ¹',        # should be رفع
    ]
    
    for corrupted in corrupted_samples:
        try:
            fixed = corrupted.encode('latin1').decode('utf-8')
            if fixed != corrupted and 'Ø' not in fixed:
                mapping[corrupted] = fixed
        except:
            pass
    
    return mapping

def fix_file_thoroughly(file_path):
    """Apply all possible fixes to a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        mapping = get_fix_mapping()
        
        # Direct replacements from mapping
        for corrupted, fixed in mapping.items():
            content = content.replace(corrupted, fixed)
        
        # Try to fix patterns that are within quotes
        def fix_quoted_strings(match):
            quote = match.group(1)
            text = match.group(2)
            
            try:
                # Try the encoding trick
                fixed = text.encode('latin1').decode('utf-8')
                if fixed != text and 'Ø' not in fixed:
                    return f'{quote}{fixed}{quote}'
            except:
                pass
            
            return match.group(0)
        
        # Fix strings in single and double quotes
        content = re.sub(r"(['\"])([^'\"]*[ØÙ][^'\"]*)\1", fix_quoted_strings, content)
        
        # Write if changed
        if content != original:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"Error in {file_path}: {e}")
        return False

def main():
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    print(f"🎯 COMPREHENSIVE CORRUPTION FIX")
    print(f"{'='*60}")
    print(f"Processing {len(dart_files)} files...\n")
    
    fixed_count = 0
    
    for file_path in dart_files:
        if fix_file_thoroughly(file_path):
            fixed_count += 1
            print(f"✅ Fixed: {file_path}")
    
    print(f"\n{'='*60}")
    print(f"Total files fixed: {fixed_count}/{len(dart_files)}")
    print(f"{'='*60}\n")

if __name__ == '__main__':
    main()
