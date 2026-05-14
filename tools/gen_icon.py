from PIL import Image, ImageDraw, ImageFont
import math, os

SIZE = 1024
OUT  = os.path.join(os.path.dirname(os.path.abspath(__file__)), "../assets/icon/app_icon.png")

BG       = (13,  11,  20)     # 배경
PURPLE   = (48,  32,  88)     # 보라 원 채우기
PURPLE_E = (62,  44, 108)     # 원 테두리
GOLD_L   = (230, 200, 119)    # 골드 라이트
GOLD     = (200, 164,  72)    # 골드 딤

img  = Image.new("RGBA", (SIZE, SIZE), BG + (255,))
draw = ImageDraw.Draw(img)
cx, cy = SIZE // 2, SIZE // 2

# ── 1. 보라색 꽉 찬 원 ───────────────────────────────────────────────────
r_circle = 440
draw.ellipse([cx-r_circle, cy-r_circle, cx+r_circle, cy+r_circle],
             fill=PURPLE+(255,), outline=PURPLE_E+(255,), width=3)

# ── 2. 얼굴 윤곽 (단일 깔끔한 선) ────────────────────────────────────────
def face_pts(ox, oy, fw, fh):
    pts = []
    for deg in range(0, 361, 1):   # 1도 간격 → 부드러운 선
        rad = math.radians(deg)
        jf  = 1.0
        if 200 < deg < 340:
            jf = 1.0 - 0.16 * max(0, 1 - abs(deg-270) / 70)
        pts.append((ox + fw*jf*math.sin(rad), oy - fh*math.cos(rad)))
    return pts

FX, FY = cx, cy - 40
FW, FH = 185, 255

draw.polygon(face_pts(FX, FY, FW, FH), outline=GOLD_L+(230,), width=2)

# ── 3. 눈썹 ──────────────────────────────────────────────────────────────
draw.line([(cx-122, FY-92), (cx-62, FY-98)], fill=GOLD_L+(180,), width=3)
draw.line([(cx+62,  FY-98), (cx+122, FY-92)], fill=GOLD_L+(180,), width=3)

# ── 4. 눈 (단순 타원) ────────────────────────────────────────────────────
def eye(ex, ey, ew=50, eh=18):
    draw.ellipse([ex-ew, ey-eh, ex+ew, ey+eh], outline=GOLD_L+(200,), width=2)

eye(cx-80, FY-54)
eye(cx+80, FY-54)

# ── 5. 코 ────────────────────────────────────────────────────────────────
draw.line([(cx, FY-36), (cx-16, FY+36), (cx-26, FY+48)],
          fill=GOLD+(160,), width=2)
draw.line([(cx-26, FY+48), (cx+26, FY+48)], fill=GOLD+(160,), width=2)
draw.line([(cx+26, FY+48), (cx+16, FY+36), (cx, FY-36)],
          fill=GOLD+(160,), width=2)

# ── 6. 입 ────────────────────────────────────────────────────────────────
def bezier(p0, p1, p2, n=60):
    return [((1-t/n)**2*p0[0]+2*(1-t/n)*(t/n)*p1[0]+(t/n)**2*p2[0],
             (1-t/n)**2*p0[1]+2*(1-t/n)*(t/n)*p1[1]+(t/n)**2*p2[1])
            for t in range(n+1)]

draw.line(bezier((cx-56, FY+118), (cx, FY+106), (cx+56, FY+118)),
          fill=GOLD_L+(185,), width=2)
draw.line(bezier((cx-50, FY+120), (cx, FY+144), (cx+50, FY+120)),
          fill=GOLD_L+(140,), width=2)

# ── 7. 랜드마크 점 5개 ───────────────────────────────────────────────────
def dot(x, y, r=5):
    draw.ellipse([x-r, y-r, x+r, y+r], fill=GOLD_L+(240,))

dot(cx,     FY - 196, 5)   # 이마
dot(cx-80,  FY - 54,  4)   # 왼눈
dot(cx+80,  FY - 54,  4)   # 오른눈
dot(cx,     FY + 48,  4)   # 코끝
dot(cx,     FY + 206, 5)   # 턱

# ── 8. AURA 텍스트 (크게) ────────────────────────────────────────────────
afont = None
for fp in ["/System/Library/Fonts/Helvetica.ttc", "/Library/Fonts/Arial.ttf"]:
    try:
        afont = ImageFont.truetype(fp, 72)
        break
    except Exception:
        pass

if afont:
    bb  = draw.textbbox((0, 0), "AURA", font=afont)
    tw  = bb[2] - bb[0]
    tx  = (SIZE - tw) // 2
    ty2 = SIZE - 148
    draw.text((tx, ty2), "AURA", font=afont, fill=GOLD_L+(210,))

os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.convert("RGB").save(OUT, "PNG", optimize=True)
print(f"saved: {OUT}")
