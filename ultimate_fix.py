#!/usr/bin/env python3
"""
FINAL ULTIMATE FIX - Handles all corruption including mixed cases
Uses character-by-character analysis and multiple decoding attempts.
"""

import os
import glob
import re

def fix_corrupted_sequence(sequence):
    """Try to fix a single corrupted sequence."""
    if not sequence:
        return sequence
    
    # Try multiple decoding strategies
    strategies = [
        lambda s: s.encode('latin1').decode('utf-8'),
        lambda s: s.encode('utf-8', errors='ignore').decode('utf-8', errors='ignore'),
    ]
    
    for strategy in strategies:
        try:
            fixed = strategy(sequence)
            # Check if it actually looks better (no more corruption markers)
            if 'Ø' not in fixed and 'ù' not in fixed and 'Ù' not in fixed:
                return fixed
        except:
            pass
    
    return sequence

def fix_file_ultimate(file_path):
    """Ultimate fix - character and pattern level."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original = content
        
        # Strategy 1: Find all corrupted sequences and fix them individually
        # Pattern: sequences containing Ø or Ù followed by combining marks
        def replacer(match):
            corrupted = match.group(0)
            fixed = fix_corrupted_sequence(corrupted)
            return fixed if fixed != corrupted else corrupted
        
        # Fix corrupted sequences (conservative - only 1-15 chars)
        content = re.sub(r'[ØÙ][\s\w±-ÿ]{0,15}', replacer, content)
        
        # Strategy 2: Fix strings in quotes that contain corrupted text
        def fix_quoted(match):
            quote = match.group(1)
            text = match.group(2)
            
            # Try to fix the entire text
            fixed = fix_corrupted_sequence(text)
            if fixed != text:
                return f'{quote}{fixed}{quote}'
            
            # If that didn't work, try fixing pieces of it
            parts = []
            for part in re.split(r'(\s+)', text):
                if part and part.strip():
                    fixed_part = fix_corrupted_sequence(part)
                    parts.append(fixed_part)
                else:
                    parts.append(part)
            
            fixed_text = ''.join(parts)
            if fixed_text != text:
                return f'{quote}{fixed_text}{quote}'
            
            return match.group(0)
        
        content = re.sub(r'(["\'])([^"\']*[ØÙ][^"\']*)\1', fix_quoted, content)
        
        # Strategy 3: Direct mapping for known patterns
        known_fixes = {
            'Ù„Ø§ ÙŠÙˆØ¬Ø¯': 'لا يوجد',
            'Ø§ØªØµØ§Ù„': 'اتصال',
            'Ø®Ø·Ø£': 'خطأ',
            'Ø¨Ù†Ø¬Ø§Ø­': 'بنجاح',
            'Ø±ÙØ¹': 'رفع',
            'Ù…Ù„Ù': 'ملف',
        }
        
        for corrupted, fixed in known_fixes.items():
            content = content.replace(corrupted, fixed)
        
        # Write if changed
        if content != original:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        
        return False
        
    except Exception as e:
        print(f"⚠️  Error in {file_path}: {e}")
        return False

def main():
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    print(f"\n🚀 ULTIMATE FINAL FIX - All Corruption Types")
    print(f"{'='*70}")
    print(f"Processing {len(dart_files)} files...\n")
    
    fixed = []
    for file_path in dart_files:
        if fix_file_ultimate(file_path):
            fixed.append(file_path)
            print(f"✅ {file_path}")
    
    print(f"\n{'='*70}")
    print(f"🎉 Total fixed: {len(fixed)}/{len(dart_files)}")
    print(f"{'='*70}\n")
    
    return len(fixed)

if __name__ == '__main__':
    result = main()
    exit(0 if result > 0 else 1)
