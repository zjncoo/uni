#!/usr/bin/env python3
import os
import shutil
import struct
import subprocess

def create_icns(png_map, output_icns_path):
    chunks = []
    for ostype, path in png_map.items():
        if os.path.exists(path):
            with open(path, "rb") as f:
                data = f.read()
            chunk_len = len(data) + 8
            chunks.append(ostype.encode('ascii') + struct.pack('>I', chunk_len) + data)
    
    body = b"".join(chunks)
    total_len = len(body) + 8
    header = b"icns" + struct.pack('>I', total_len)
    with open(output_icns_path, "wb") as f:
        f.write(header + body)
    print(f"Created {output_icns_path} ({total_len} bytes)")

def main():
    svg_source = """<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <defs>
    <filter id="macShadow" x="-15%" y="-15%" width="130%" height="135%">
      <feDropShadow dx="0" dy="24" stdDeviation="28" flood-color="#000000" flood-opacity="0.12" />
      <feDropShadow dx="0" dy="6" stdDeviation="10" flood-color="#000000" flood-opacity="0.06" />
    </filter>
  </defs>
  <!-- Pure White Squircle -->
  <rect x="100" y="100" width="824" height="824" rx="185" ry="185" fill="#FFFFFF" filter="url(#macShadow)" />
  <rect x="100" y="100" width="824" height="824" rx="185" ry="185" fill="none" stroke="rgba(0,0,0,0.07)" stroke-width="1.5" />
  <!-- Three Black Slashes /// in sans font -->
  <text x="512" y="640" font-family="-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', 'Inter', sans-serif" font-size="520" font-weight="800" text-anchor="middle" fill="#000000" letter-spacing="-16">///</text>
</svg>"""

    with open("master_icon.svg", "w") as f:
        f.write(svg_source)

    subprocess.run(["sips", "-s", "format", "png", "master_icon.svg", "--out", "master_icon.png"], check=True)

    iconset_dir = "AppIcon.iconset"
    os.makedirs(iconset_dir, exist_ok=True)

    sizes = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
        ("icon_1024x1024.png", 1024),
    ]

    for filename, sz in sizes:
        dest_path = os.path.join(iconset_dir, filename)
        subprocess.run(["sips", "-z", str(sz), str(sz), "master_icon.png", "--out", dest_path], check=True)

    # Build icns
    icns_map = {
        'icp4': os.path.join(iconset_dir, 'icon_16x16.png'),
        'icp5': os.path.join(iconset_dir, 'icon_32x32.png'),
        'icp6': os.path.join(iconset_dir, 'icon_32x32@2x.png'),
        'ic07': os.path.join(iconset_dir, 'icon_128x128.png'),
        'ic08': os.path.join(iconset_dir, 'icon_256x256.png'),
        'ic09': os.path.join(iconset_dir, 'icon_512x512.png'),
        'ic10': os.path.join(iconset_dir, 'icon_512x512@2x.png'),
    }
    create_icns(icns_map, "AppIcon.icns")

    # Copy files to appiconset destinations
    dest_dirs = [
        "uni/Assets.xcassets/AppIcon.appiconset",
        "docs/assets/uni-macos/uni/Assets.xcassets/AppIcon.appiconset"
    ]
    for d in dest_dirs:
        if os.path.isdir(d):
            for filename, sz in sizes:
                src = os.path.join(iconset_dir, filename)
                dst = os.path.join(d, filename)
                shutil.copyfile(src, dst)
            print(f"Updated iconset in {d}")

    # Copy standalone AppIcon.png (1024) and docs assets
    shutil.copyfile("master_icon.png", "uni/AppIcon.png")
    shutil.copyfile("master_icon.png", "docs/assets/icon.png")
    shutil.copyfile(os.path.join(iconset_dir, "icon_32x32@2x.png"), "docs/assets/favicon.png")
    
    if os.path.exists("docs/assets/uni-macos/uni"):
        shutil.copyfile("master_icon.png", "docs/assets/uni-macos/uni/AppIcon.png")
    if os.path.exists("docs/assets/uni-macos/docs/assets"):
        shutil.copyfile("master_icon.png", "docs/assets/uni-macos/docs/assets/icon.png")
        shutil.copyfile(os.path.join(iconset_dir, "icon_32x32@2x.png"), "docs/assets/uni-macos/docs/assets/favicon.png")

    print("All icon assets generated and distributed successfully!")

if __name__ == "__main__":
    main()
