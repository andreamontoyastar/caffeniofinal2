import urllib.request
urls = [
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/americano.png',
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/capuchino.png',
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/cafe1.png',
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/cafe2.png',
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/cafe3.png',
    'https://raw.githubusercontent.com/montoya06470/Imagenes-para-flutter-6to-l-fecha-11-feb-2026/refs/heads/main/cafe4.png'
]
for url in urls:
    try:
        with urllib.request.urlopen(url, timeout=10) as resp:
            print(url, resp.status, resp.getheader('Content-Type'))
    except Exception as e:
        print(url, 'ERROR', type(e).__name__, e)
