import re
import os
import subprocess
from PIL import Image

def generate():
    svg_path = 'assets/icons/swastiklogo.svg'
    with open(svg_path, 'r', encoding='utf-8') as f:
        svg_content = f.read()

    lines = svg_content.splitlines()
    # Line 0 is svg tag
    # Line 1 is the SWASTIK text path
    # Lines 2..end are emblem and defs
    
    emblem_body = '\n'.join(lines[2:])
    
    # HTML template with dark emerald luxury background, gold rim, and centered emblem
    html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }}
  body {{
    width: 512px;
    height: 512px;
    background: transparent;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
  }}
  .icon-container {{
    width: 512px;
    height: 512px;
    border-radius: 112px; /* Smooth rounded squircle matching modern Android / OneUI / MIUI */
    background: radial-gradient(circle at 35% 30%, #0d3b2e 0%, #05241c 55%, #02120e 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    box-shadow: inset 0 0 0 10px rgba(220, 168, 49, 0.45), inset 0 0 24px rgba(0, 0, 0, 0.6);
  }}
  .inner-border {{
    position: absolute;
    width: 480px;
    height: 480px;
    border-radius: 96px;
    border: 2px solid rgba(220, 168, 49, 0.25);
    pointer-events: none;
  }}
  .crest {{
    width: 330px;
    height: 330px;
    filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.5)) drop-shadow(0 2px 4px rgba(220, 168, 49, 0.3));
  }}
</style>
</head>
<body>
  <div class="icon-container">
    <div class="inner-border"></div>
    <svg class="crest" viewBox="-2 -2 51 51" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
      {emblem_body}
    </svg>
  </div>
</body>
</html>
"""
    os.makedirs('build/icon_gen', exist_ok=True)
    html_file = os.path.abspath('build/icon_gen/icon.html')
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)

    screenshot_png = os.path.abspath('build/icon_gen/icon_512.png')
    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    
    cmd = [
        edge_path,
        "--headless",
        "--disable-gpu",
        "--screenshot=" + screenshot_png,
        "--window-size=512,512",
        "--hide-scrollbars",
        "--default-background-color=00000000",
        f"file:///{html_file.replace(os.sep, '/')}"
    ]
    print("Running Edge screenshot...")
    subprocess.run(cmd, check=True)
    print("Screenshot generated:", screenshot_png)

    # Now open with PIL and generate all mipmap sizes
    img = Image.open(screenshot_png).convert('RGBA')
    # Crop to 512x512 if window-size included any decoration
    if img.size != (512, 512):
        img = img.crop((0, 0, 512, 512))

    densities = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    for folder, size in densities.items():
        res_dir = os.path.join('android', 'app', 'src', 'main', 'res', folder)
        os.makedirs(res_dir, exist_ok=True)
        out_path = os.path.join(res_dir, 'ic_launcher.png')
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(out_path, 'PNG')
        print(f"Saved {out_path} ({size}x{size})")

    # Also save a 512x512 play store icon and round icons just in case
    for folder, size in densities.items():
        res_dir = os.path.join('android', 'app', 'src', 'main', 'res', folder)
        out_round = os.path.join(res_dir, 'ic_launcher_round.png')
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(out_round, 'PNG')

    # Save to artifacts for inspection
    artifact_path = r"C:\Users\DELL\.gemini\antigravity\brain\d8e41d13-baf3-4983-9e9f-c789e52e9382\app_icon_preview.png"
    img.save(artifact_path, 'PNG')
    print("Saved artifact preview to:", artifact_path)

if __name__ == '__main__':
    generate()
