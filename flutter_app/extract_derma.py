import base64
import re

with open(r'assets/icons/Derma.txt', 'r') as f:
    content = f.read()

idx = content.find('base64,')
if idx == -1:
    print('No encontrado base64 en Derma.txt')
else:
    tail = content[idx + 7:]
    end = tail.find('"')
    b64 = tail[:end].replace('\n','').replace('\r','').replace(' ','')
    data = base64.b64decode(b64)
    with open(r'assets/icons/Derma.png', 'wb') as out:
        out.write(data)
    print('OK Derma.png: ' + str(len(data)) + ' bytes')
