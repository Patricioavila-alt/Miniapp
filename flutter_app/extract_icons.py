import base64, re

def extract_png(src_path, dst_path):
    with open(src_path, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    idx = content.find('base64,')
    if idx == -1:
        print(f'No base64 in {src_path}')
        return
    tail = content[idx + 7:]
    end  = tail.find('"')
    b64  = tail[:end].replace('\n','').replace('\r','').replace(' ','')
    data = base64.b64decode(b64)
    with open(dst_path, 'wb') as out:
        out.write(data)
    print(f'OK {dst_path}: {len(data)} bytes')

extract_png(r'assets/icons/Derma.txt',       r'assets/icons/Derma.png')
extract_png(r'assets/icons/Expediente.svg',  r'assets/icons/Expediente.png')
