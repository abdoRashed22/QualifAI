#!/usr/bin/env python3
"""
QualifAI — Fix All Encoding Issues
Run from: E:\Projects\qualif_ai
Command: python FIX_ALL.py
"""
import os
import glob
import re

def fix_file_encoding(file_path):
    """
    Fix corrupted Arabic text in Dart files.
    Corruption happens when PowerShell writes UTF-8 files without BOM
    and the file gets interpreted as Latin-1.
    Fix: read as Latin-1 -> encode -> decode as UTF-8.
    """
    try:
        # Try reading as UTF-8 first
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if content has corrupted patterns (ØÙ patterns mixed with ASCII)
        corrupted = bool(re.search(r'[\xc3\xc2][\x80-\xbf]|Ø[\xa7-\xb0]|Ù[\x84-\x86]', content))
        
        # Also check for the visual corruption pattern
        has_corruption = bool(re.search(r'Ø[a-zA-Z¡-ÿ]|Ù[a-zA-Z¡-ÿ0-9]', content))
        
        if not has_corruption:
            return False, "clean"
        
        # Try Latin-1 -> UTF-8 decode
        with open(file_path, 'rb') as f:
            raw_bytes = f.read()
        
        try:
            # If the file was saved as UTF-8 but read as Latin-1
            fixed = raw_bytes.decode('utf-8', errors='replace')
            if fixed != content and not re.search(r'Ø[a-zA-Z¡-ÿ]|Ù[a-zA-Z¡-ÿ0-9]', fixed):
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(fixed)
                return True, "fixed via utf-8 re-read"
        except:
            pass
        
        try:
            # The classic PowerShell encoding bug: UTF-8 bytes read as Latin-1
            fixed = raw_bytes.decode('latin-1').encode('latin-1').decode('utf-8')
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(fixed)
            return True, "fixed via latin1->utf8"
        except Exception as e:
            return False, f"failed: {e}"
            
    except Exception as e:
        return False, str(e)

# Find all Dart files
dart_files = glob.glob('lib/**/*.dart', recursive=True)
dart_files.extend(glob.glob('lib/*.dart'))

print(f"\nQualifAI Encoding Fix")
print(f"{'='*40}")
print(f"Scanning {len(dart_files)} Dart files...\n")

fixed = 0
clean = 0
failed = 0

for fp in sorted(dart_files):
    ok, msg = fix_file_encoding(fp)
    if ok:
        fixed += 1
        print(f"  FIXED  {fp}")
    elif msg == "clean":
        clean += 1
    else:
        failed += 1
        print(f"  ERROR  {fp}: {msg}")

print(f"\n{'='*40}")
print(f"Fixed:  {fixed} files")
print(f"Clean:  {clean} files")
print(f"Failed: {failed} files")
print(f"Total:  {len(dart_files)} files")

if fixed > 0:
    print(f"\nNow run: flutter run")
else:
    print(f"\nNo encoding issues found. If Arabic is still broken,")
    print(f"run WRITE_FILES_V2.ps1 to rewrite all files cleanly.")
