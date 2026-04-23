#!/usr/bin/env python3
import re

samples = [
    'Ã™Æ'Ã™Å Ã™Ë†Ã™â€žÃ™Å Ã™',
    'Ã™â€ Ã˜Â¸Ã˜Â§Ã™â€¦',
    'Ã™â€žÃ˜Â§ Ã™Å Ã™Ë†Ã˜Â¬Ã˜Â¯',
    'Ã˜Â§Ã˜ÂªÃ˜ÂµÃ˜Â§Ã™â€ž',
    'Ã˜Â®Ã˜Â·Ã˜Â£',
    'Ã™Å Ã™Ë†Ã˜Â¬Ã˜Â¯',
]

print(f
DIAGNOSTIC ANALYSIS OF CORRUPTED TEXT')
print(f'{'='*70}
')

for i, sample in enumerate(samples, 1):
    print(f'Sample {i}: {sample}')
    print(f'  Length: {len(sample)} chars')
    print(f'  Bytes (UTF-8): {sample.encode("utf-8").hex()}')
    
    try:
        latin1_hex = sample.encode('latin-1').hex()
        print(f'  Bytes (Latin-1): {latin1_hex}')
    except Exception as e:
        print(f'  Bytes (Latin-1): CANNOT ENCODE - {type(e).__name__}')
    
    print(f'  Decode attempts:')
    
    try:
        result = sample.encode('latin-1').decode('utf-8')
        print(f'    latin-1→utf-8: {result}')
    except Exception as e:
        print(f'    latin-1→utf-8: FAILED ({type(e).__name__})')
    
    utf8_bytes = sample.encode('utf-8')
    try:
        as_iso88591 = utf8_bytes.decode('iso-8859-1')
        print(f'    UTF8-bytes→iso-8859-1: {as_iso88591}')
    except:
        pass
    
    print()
