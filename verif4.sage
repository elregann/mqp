import secrets
from math import log2

p = next_prime(2^16)
d = 3
Zp = Integers(p)

R = PolynomialRing(Zp, 'X')
X = R.gen()
Q = R.quotient(X^d - 1, 'x')

def f_mqp(x, y):
    return x * y

# ───────────────────────────────────────────────
# Setup witness
# ───────────────────────────────────────────────
x_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
y_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
a      = f_mqp(x_true, y_true)

print(f"p={int(p)}, d={d}")
print(f"a = {a}")

# ───────────────────────────────────────────────
# DUAL-Pa via R_Q:
# Ide: Pa_0 dan Pa_1 dibuat dari MODUL yang sama
# tapi via PROYEKSI RING yang berbeda
#
# Pa_0: {x ∈ R_Q | x * y_true = a}  (fix y, vary x)
# Pa_1: {y ∈ R_Q | x_true * y = a}  (fix x, vary y)
#
# Keduanya dari witness yang SAMA
# tapi "view" berbeda — x-space vs y-space
# ───────────────────────────────────────────────
print("\n=== DUAL-Pa VIA RING PROJECTION ===")

n = 10

# Pa_0: vary x, y = a/x
Pa_0 = []
for _ in range(n):
    x_r = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    try:
        y_r = a / x_r
        if f_mqp(x_r, y_r) == a:
            Pa_0.append(x_r)
    except:
        pass

# Pa_1: vary y, x = a/y
Pa_1 = []
for _ in range(n):
    y_r = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    try:
        x_r = a / y_r
        if f_mqp(x_r, y_r) == a:
            Pa_1.append(y_r)
    except:
        pass

print(f"  |Pa_0| generated: {len(Pa_0)}")
print(f"  |Pa_1| generated: {len(Pa_1)}")

# ───────────────────────────────────────────────
# Test 1: Apakah Pa_0 dan Pa_1 leak intersection?
# ───────────────────────────────────────────────
print("\n=== TEST 1: INTERSECTION LEAK ===")

# Convert ke set of tuples untuk comparison
set_0 = set(tuple(int(c) for c in xr.lift().coefficients(sparse=False)+[0]*(d-len(xr.lift().coefficients(sparse=False)))) for xr in Pa_0)
set_1 = set(tuple(int(c) for c in yr.lift().coefficients(sparse=False)+[0]*(d-len(yr.lift().coefficients(sparse=False)))) for yr in Pa_1)

intersection = set_0 & set_1
print(f"  |Pa_0 ∩ Pa_1| = {len(intersection)}")
print(f"  Leak via intersection: {len(intersection) > 0}")

# ───────────────────────────────────────────────
# Test 2: Efisiensi — berapa banyak info per element
# QP biasa: x ∈ Zp (1 nilai)
# MQP: x ∈ R_Q (d nilai sekaligus)
# ───────────────────────────────────────────────
print("\n=== TEST 2: EFISIENSI ===")
print(f"  QP biasa: 1 elemen = 1 nilai di Zp")
print(f"  MQP:      1 elemen = {d} nilai di R_Q")
print(f"  Efisiensi gain: {d}x lebih kompak")
print(f"  |Pa| QP biasa : p = {int(p):.2e}")
print(f"  |Pa| MQP      : p^d = {int(p)^d:.2e}")
print(f"  Security gain : {float(log2(int(p)^d)):.1f} bits vs {float(log2(int(p))):.1f} bits")

# ───────────────────────────────────────────────
# Test 3: Apakah Pa_0 (x-space) dan Pa_1 (y-space)
# distribusinya identik?
# Kunci: Pa_0 adalah x-projection, Pa_1 adalah y-projection
# Keduanya BERBEDA domain tapi SAMA distribusi
# ───────────────────────────────────────────────
print("\n=== TEST 3: DISTRIBUSI Pa_0 vs Pa_1 ===")

N = 10000
coeff0_x = []  # koefisien[0] dari Pa_0
coeff0_y = []  # koefisien[0] dari Pa_1

for _ in range(N):
    xr = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    try:
        yr = a / xr
        if f_mqp(xr, yr) == a:
            coeffs_x = xr.lift().coefficients(sparse=False)
            coeffs_y = yr.lift().coefficients(sparse=False)
            if coeffs_x:
                coeff0_x.append(int(coeffs_x[0]))
            if coeffs_y:
                coeff0_y.append(int(coeffs_y[0]))
    except:
        pass

mean_x = float(sum(coeff0_x))/float(len(coeff0_x)) if coeff0_x else 0
mean_y = float(sum(coeff0_y))/float(len(coeff0_y)) if coeff0_y else 0
expected = float(p)/float(2)

print(f"  Mean coeff[0] Pa_0 (x): {float(mean_x):.2f}")
print(f"  Mean coeff[0] Pa_1 (y): {float(mean_y):.2f}")
print(f"  Expected (p/2)         : {float(expected):.2f}")
print(f"  Pa_0 uniform: {abs(float(mean_x)-float(expected)) < float(p)/float(10)}")
print(f"  Pa_1 uniform: {abs(float(mean_y)-float(expected)) < float(p)/float(10)}")
print(f"  Distribusi identik: {abs(float(mean_x)-float(mean_y)) < float(p)/float(10)}")

print("\n=== RINGKASAN VERIFIKASI 4 ===")
print(f"  Intersection leak : {len(intersection) > 0}")
print(f"  Efisiensi gain    : {d}x lebih kompak")
print(f"  Pa_0 uniform      : {abs(float(mean_x)-float(expected)) < float(p)/float(10)}")
print(f"  Pa_1 uniform      : {abs(float(mean_y)-float(expected)) < float(p)/float(10)}")
print(f"  Dual-Pa via R_Q   : {len(intersection) == 0 and abs(float(mean_x)-float(mean_y)) < float(p)/float(10)}")
