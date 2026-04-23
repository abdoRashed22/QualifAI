#!/usr/bin/env python3
"""
Read files as raw bytes and attempt proper reconstruction
"""

import os
import glob

def analyze_file_bytes(file_path):
    """Read file as bytes and analyze."""
    with open(file_path, 'rb') as f:
        raw_bytes = f.read()
    
    # Try different decodings
    attempts = {}
    
    # UTF-8 (current)
    try:
        attempts['utf-8'] = raw_bytes.decode('utf-8')
    except:
        attempts['utf-8'] = None
    
    # UTF-8 with replacement
    attempts['utf-8-replace'] = raw_bytes.decode('utf-8', errors='replace')
    
    # Latin-1 (might work for PowerShell issue)
    try:
        attempts['latin-1'] = raw_bytes.decode('latin-1')
    except:
        attempts['latin-1'] = None
    
    # UTF-16 (common Windows encoding)
    try:
        attempts['utf-16'] = raw_bytes.decode('utf-16')
    except:
        attempts['utf-16'] = None
    
    return raw_bytes, attempts

# Check a specific file
file_path = 'lib/core/localization/app_strings.dart'

print(f"Analyzing: {file_path}\n")

raw_bytes, attempts = analyze_file_bytes(file_path)

print(f"File size: {len(raw_bytes)} bytes\n")

# Show first 200 bytes in different encodings
print(f"First 100 bytes (hex): {raw_bytes[:100].hex()}\n")

for encoding, content in attempts.items():
    if content:
        print(f"\n{encoding}:")
        print(f"  First line: {content.split(chr(10))[0][:80]}")
        print(f"  Has 'Ù': {'Ù' in content}")
        print(f"  Has 'ØØ': {'Ø' in content}")
        print(f"  Has 'مرحبا': {'مرحبا' in content}")
