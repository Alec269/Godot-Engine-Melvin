#!/usr/bin/env python
# -*- coding: utf-8 -*-

## dont change the above

# import sys

# if len(sys.argv) < 2:
#     print("Invalid usage of file_format.py, it should be called with a path to one or multiple files.")
#     sys.exit(1)

# BOM = b"\xef\xbb\xbf"

# changed = []
# invalid = []

# for file in sys.argv[1:]:
#     try:
#         with open(file, "rt", encoding="utf-8") as f:
#             original = f.read()
#     except UnicodeDecodeError:
#         invalid.append(file)
#         continue

#     if original == "":
#         continue

#     EOL = "\r\n" if file.endswith((".csproj", ".sln", ".bat")) or file.startswith("misc/msvs") else "\n"
#     WANTS_BOM = file.endswith((".csproj", ".sln"))

#     revamp = EOL.join([line.rstrip("\n\r\t ") for line in original.splitlines(True)]).rstrip(EOL) + EOL

#     new_raw = revamp.encode(encoding="utf-8")
#     if not WANTS_BOM and new_raw.startswith(BOM):
#         new_raw = new_raw[len(BOM) :]
#     elif WANTS_BOM and not new_raw.startswith(BOM):
#         new_raw = BOM + new_raw

#     with open(file, "rb") as f:
#         old_raw = f.read()

#     if old_raw != new_raw:
#         changed.append(file)
#         with open(file, "wb") as f:
#             f.write(new_raw)

# if changed:
#     for file in changed:
#         print(f"FIXED: {file}")
# if invalid:
#     for file in invalid:
#         print(f"REQUIRES MANUAL CHANGES: {file}")
#     sys.exit(1)



import sys
import os

if len(sys.argv) < 2:
    print("Invalid usage of file_format.py, it should be called with a path to one or multiple files.")
    sys.exit(1)

BOM = b"\xef\xbb\xbf"
changed = []
invalid = []

def should_use_lf(file_path):
    """Determine if a file should use LF line endings based on your requirements."""
    file_lower = file_path.lower()
    filename = os.path.basename(file_path)

    # Force LF for these specific files and extensions
    lf_files = [
        '.gitignore',
        '.gitattributes'
    ]

    lf_extensions = [
        '.sh',
        '.bash'
    ]

    # Check for specific filenames
    if filename in lf_files:
        return True

    # Check for extensions
    for ext in lf_extensions:
        if file_lower.endswith(ext):
            return True

    return False

for file in sys.argv[1:]:
    try:
        with open(file, "rt", encoding="utf-8") as f:
            original = f.read()
    except UnicodeDecodeError:
        invalid.append(file)
        continue

    if original == "":
        continue

    # Determine line ending based on your rules
    if should_use_lf(file):
        EOL = "\n"
    else:
        EOL = "\r\n"

    # Handle BOM (only for .csproj and .sln files)
    WANTS_BOM = file.endswith((".csproj", ".sln"))

    # Process the file content
    revamp = EOL.join([line.rstrip("\n\r\t ") for line in original.splitlines(True)]).rstrip(EOL) + EOL
    new_raw = revamp.encode(encoding="utf-8")

    # Handle BOM
    if not WANTS_BOM and new_raw.startswith(BOM):
        new_raw = new_raw[len(BOM) :]
    elif WANTS_BOM and not new_raw.startswith(BOM):
        new_raw = BOM + new_raw

    # Read the current file content
    with open(file, "rb") as f:
        old_raw = f.read()

    # Only write if there are changes
    if old_raw != new_raw:
        changed.append(file)
        with open(file, "wb") as f:
            f.write(new_raw)

if changed:
    for file in changed:
        print(f"FIXED: {file}")

if invalid:
    for file in invalid:
        print(f"REQUIRES MANUAL CHANGES: {file}")
    sys.exit(1)
