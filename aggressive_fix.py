#!/usr/bin/env python3
"""
Aggressive corrupted text fix - handles all edge cases.
"""

import os
import glob
import re

def aggressive_fix(file_path):
    """Read file as binary, attempt all possible fixes."""
    
    try:
        with open(file_path, 'rb') as f:
            raw_bytes = f.read()
        
        # Try different decodings to find which one works best
        attempts = []
        
        # 1. Try UTF-8 (current)
        try:
            utf8_decoded = raw_bytes.decode('utf-8')
            attempts.append(('utf-8', utf8_decoded))
        except:
            pass
        
        # 2. Try Latin-1 -> UTF-8 (PowerShell bug fix)
        try:
            latin1_str = raw_bytes.decode('latin-1')
            utf8_redecoded = latin1_str.encode('latin-1').decode('utf-8')
            attempts.append(('latin1->utf8', utf8_redecoded))
        except:
            pass
        
        # 3. Try to fix character by character for mixed content
        try:
            utf8_decoded = raw_bytes.decode('utf-8')
            
            # Find and fix corrupted sequences within the string
            fixed = utf8_decoded
            
            # Pattern for corrupted UTF-8: appears as Ø Ù characters
            # These are actually UTF-8 bytes being displayed as Latin-1
            # Try to identify blocks and fix them
            
            parts = []
            current_pos = 0
            
            for match in re.finditer(r'[ØÙ][\w±-ÿ]{0,10}', fixed):
                # Add the non-corrupted part
                parts.append(fixed[current_pos:match.start()])
                
                # Try to fix the corrupted part
                corrupted = match.group(0)
                try:
                    fixed_part = corrupted.encode('latin-1').decode('utf-8')
                    parts.append(fixed_part)
                except:
                    parts.append(corrupted)
                
                current_pos = match.end()
            
            # Add remaining part
            parts.append(fixed[current_pos:])
            fixed_content = ''.join(parts)
            attempts.append(('regex_fix', fixed_content))
        except:
            pass
        
        # Pick the best attempt (one with least corruption markers)
        best = None
        best_score = float('inf')
        
        for method, content in attempts:
            # Score based on corruption markers
            score = content.count('Ø') + content.count('Ù') * 2 + content.count('â')
            if score < best_score:
                best_score = score
                best = content
        
        if best and best_score == 0:
            # Write the fixed version
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(best)
            return True
        
        return False
        
    except Exception as e:
        print(f"  Error processing {file_path}: {e}")
        return False

def main():
    dart_files = sorted(glob.glob('lib/**/*.dart', recursive=True))
    
    print(f"\n🔬 AGGRESSIVE CORRUPTION FIX (Binary Analysis)")
    print(f"{'='*70}")
    print(f"Processing {len(dart_files)} files...\n")
    
    fixed = []
    
    for file_path in dart_files:
        if aggressive_fix(file_path):
            fixed.append(file_path)
            print(f"✅ {file_path}")
    
    print(f"\n{'='*70}")
    print(f"🎉 Total fixed: {len(fixed)}/{len(dart_files)}")
    
    if fixed:
        print(f"\nFiles fixed:")
        for f in fixed:
            print(f"  - {f}")
    
    print(f"{'='*70}\n")

if __name__ == '__main__':
    main()
