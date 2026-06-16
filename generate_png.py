import base64
import zlib
import urllib.request
import os

def encode_kroki(text):
    compressed = zlib.compress(text.encode('utf-8'), 9)
    return base64.urlsafe_b64encode(compressed).decode('utf-8')

def generate_dfd():
    filepath = 'dfd_process_1.mmd'
    if not os.path.exists(filepath):
        print(f"File {filepath} not found.")
        return

    with open(filepath, 'r', encoding='utf-8') as f:
        diagram = f.read()

    encoded = encode_kroki(diagram)
    url = f"https://kroki.io/mermaid/png/{encoded}"
    output_filename = "dfd_process_1.png"
    
    print(f"Generating image. This might take a few seconds...")
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(output_filename, 'wb') as out_file:
            out_file.write(response.read())
        print(f"Success! {output_filename} has been saved.")
    except Exception as e:
        print(f"Failed to download the image: {e}")

if __name__ == "__main__":
    generate_dfd()
