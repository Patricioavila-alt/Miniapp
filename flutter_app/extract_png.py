import os
import re
import base64

folder = r'c:/Users/TIC1119/Desktop/AI mockups/Salud DIgital/MiniApp/Miniapp/flutter_app/assets/icons'
pattern = re.compile(r'data:image/png;base64,([^\"\'\s>]+)')

for filename in os.listdir(folder):
    if filename.endswith('.svg'):
        filepath = os.path.join(folder, filename)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            match = pattern.search(content)
            if match:
                b64_data = match.group(1)
                png_filepath = os.path.join(folder, filename.replace('.svg', '.png'))
                with open(png_filepath, 'wb') as img_f:
                    img_f.write(base64.b64decode(b64_data))
                print(f'Extracted PNG for {filename}')
            else:
                print(f'No embedded PNG in {filename}')
