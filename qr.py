# Il QR del sito: l'indirizzo non cambia, quindi si genera una volta e si
# spedisce come file. Niente librerie da caricare nel browser.
#   pip install segno && python3 qr.py
import segno

URL = "https://muccaugo.github.io/DemoInterattive/"
qr = segno.make(URL, error="m")
qr.save("qr.svg", kind="svg", scale=10, border=2,
        dark="#14172b", light="#ffffff", svgclass=None, lineclass=None)
print("qr.svg —", qr.designator, "→", URL)
