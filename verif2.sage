import secrets
from collections import Counter
from math import log2

p = next_prime(2^16)
d = 3
Zp = Integers(p)

R = PolynomialRing(Zp, 'X')
X = R.gen()
Q = R.quotient(X^d - 1, 'x')

def f_mqp(x, y):
    return x * y

# Fixed a
x_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
y_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
a      = f_mqp(x_true, y_true)

print(f"p={int(p)}, d={d}")
print(f"a = {a}")

# ───────────────────────────────────────────────
# Test uniformity: sample banyak x_r dari Pa
# check apakah koefisien x_r terdistribusi uniform
# ───────────────────────────────────────────────
N       = 50000
coeff_0 = []  # koefisien pertama dari x_r

for _ in range(N):
    x_r = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    if x_r == Q(0):
        continue
    try:
        y_r = a / x_r
        if f_mqp(x_r, y_r) == a:
            coeff_0.append(int(x_r.lift()[0]))
    except:
        pass

# Chi-square test pada koefisien pertama
n_buckets = 20
buckets   = [0] * n_buckets
for c in coeff_0:
    buckets[int(c * n_buckets / int(p))] += 1

expected  = float(len(coeff_0)) / float(n_buckets)
chi_sq    = sum((float(b) - expected)^2 / expected for b in buckets)
critical  = float(31.41)

print(f"\nSamples collected : {len(coeff_0)}")
print(f"Chi-square        : {float(chi_sq):.4f}")
print(f"Critical (df=19)  : {critical}")
print(f"Uniform?          : {float(chi_sq) < critical}")

# Statistical distance antara x_true dan x_r dari Pa
# Apakah x_true terlihat sama dengan elemen Pa lain?
mean_c = float(sum(coeff_0)) / float(len(coeff_0))
expected_mean = float(p) / float(2)

print(f"\nMean coeff[0]     : {float(mean_c):.2f}")
print(f"Expected (p/2)    : {float(expected_mean):.2f}")
print(f"Bias detectable   : {abs(float(mean_c) - float(expected_mean)) > float(p)/float(10)}")
print(f"x_true indistinguishable: {abs(float(mean_c) - float(expected_mean)) < float(p)/float(10)}")
