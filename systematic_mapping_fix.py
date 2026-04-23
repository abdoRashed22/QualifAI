#!/usr/bin/env python3
"""
Extract all corrupted patterns and create comprehensive mapping,
then apply all fixes systematically.
"""

import os
import glob
import re

def extract_corrupted_patterns(file_path):
    """Extract all corrupted strings from a file."""
    patterns = set()
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Find all strings in quotes containing Ø or Ù
        matches = re.findall(r"['\"]([^'\"]*[ØÙ][^'\"]*)['\"]", content)
        for match in matches:
            patterns.add(match)
    except:
        pass
    
    return patterns

def build_complete_mapping():
    """Build a comprehensive mapping of all corrupted patterns."""
    mapping = {}
    
    # Collect all corrupted patterns from all files
    all_patterns = set()
    dart_files = glob.glob('lib/**/*.dart', recursive=True)
    
    for file_path in dart_files:
        all_patterns.update(extract_corrupted_patterns(file_path))
    
    print(f"Found {len(all_patterns)} unique corrupted patterns\n")
    
    # Try to fix each one
    for pattern in sorted(all_patterns):
        try:
            fixed = pattern.encode('latin1').decode('utf-8')
            if fixed != pattern and 'Ø' not in fixed and 'ù' not in fixed:
                mapping[pattern] = fixed
                print(f"  ✓ {pattern[:20]:20s} → {fixed[:20]}")
        except:
            print(f"  ✗ {pattern[:20]:20s} (cannot fix)")
    
    return mapping

def apply_mapping_to_files(mapping):
    """Apply the mapping to all files."""
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    fixed_count = 0
    for file_path in dart_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original = content
            
            # Apply all mappings
            for corrupted, fixed in mapping.items():
                content = content.replace(corrupted, fixed)
            
            if content != original:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                fixed_count += 1
                print(f"✅ {file_path}")
        except Exception as e:
            print(f"⚠️  Error in {file_path}: {e}")
    
    return fixed_count

def main():
    print(f"\n{'='*70}")
    print(f"SYSTEMATIC CORRUPTION FIX - Build Complete Mapping")
    print(f"{'='*70}\n")
    
    print(f"Step 1: Extracting all corrupted patterns...")
    print(f"{'='*70}\n")
    
    mapping = build_complete_mapping()
    
    print(f"\n{'='*70}")
    print(f"Step 2: Applying mapping to all files...")
    print(f"{'='*70}\n")
    
    fixed = apply_mapping_to_files(mapping)
    
    print(f"\n{'='*70}")
    print(f"SUMMARY:")
    print(f"  Unique corrupted patterns found: {len(mapping)}")
    print(f"  Files fixed: {fixed}")
    print(f"{'='*70}\n")

if __name__ == '__main__':
    main()
