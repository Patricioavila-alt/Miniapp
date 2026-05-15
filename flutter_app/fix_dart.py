import os
import re

base = r'c:\Users\TIC1119\Desktop\AI mockups\Salud DIgital\MiniApp\Miniapp\flutter_app\lib'

SVG_IMPORT = "import 'package:flutter_svg/flutter_svg.dart';"
MATERIAL_IMPORT = "import 'package:flutter/material.dart';"

fixed = []

for root, dirs, files in os.walk(base):
    for fname in files:
        if not fname.endswith('.dart'):
            continue
        path = os.path.join(root, fname)
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        original = content
        changed = False

        # 1. Add missing flutter_svg import
        if 'SvgPicture.asset' in content and SVG_IMPORT not in content:
            content = content.replace(MATERIAL_IMPORT, MATERIAL_IMPORT + '\n' + SVG_IMPORT, 1)
            changed = True
            print(f'[IMPORT FIXED] {fname}')

        # 2. Fix bad indent of _buildCustomStepper (4 spaces instead of 2)
        # Pattern: "    Widget _buildCustomStepper()" -> "  Widget _buildCustomStepper()"
        if '    Widget _buildCustomStepper()' in content:
            content = content.replace('    Widget _buildCustomStepper()', '  Widget _buildCustomStepper()', 1)
            changed = True
            print(f'[INDENT FIXED] {fname}')

        # 3. Check if the class is missing its closing brace after _buildCustomStepper
        # The stepper function block ends with "  }\n" and then there's no "}" for the class
        # We detect: ends of file where last non-empty line is "  }" (not "}")
        lines = content.splitlines()
        non_empty = [l.rstrip() for l in lines if l.strip()]
        if non_empty and non_empty[-1] == '  }' and '_buildCustomStepper' in content:
            # Find last occurrence of the stepper closing brace pattern and add class closing brace
            # Pattern: the stepper ends with "  }\n" at end of file  
            content = content.rstrip()
            # Remove trailing carriage returns / whitespace
            if content.endswith('  }'):
                content = content + '\n}\n'
                changed = True
                print(f'[BRACE FIXED] {fname}')

        if changed:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            fixed.append(fname)

print(f'\nTotal files fixed: {len(fixed)}')
for f in fixed:
    print(f'  - {f}')
