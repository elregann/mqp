import secrets

p = next_prime(2^16)   # kecil untuk exhaustive check
d = 3                   # dimensi module
Zp = Integers(p)

# Ring R_Q = Zp[X] / (X^d - 1)
R = PolynomialRing(Zp, 'X')
X = R.gen()
Q = R.quotient(X^d - 1, 'x')

def f_mqp(x, y):
    return x * y   # konvolusi siklik via ring multiplication

# True witness
x_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
y_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
a      = f_mqp(x_true, y_true)

print(f"p={int(p)}, d={d}")
print(f"x_true = {x_true}")
print(f"y_true = {y_true}")
print(f"a      = {a}")
print(f"f(x*,y*) = a: {f_mqp(x_true, y_true) == a}")

# Hitung |Pa| empiris via sampling
N      = 100000
pa_count = 0
for _ in range(N):
    x_r = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    if x_r == Q(0):
        continue
    # Untuk x_r != 0, cari y_r = a / x_r (jika invertible)
    try:
        y_r = a / x_r
        if f_mqp(x_r, y_r) == a:
            pa_count += 1
    except:
        pass

print(f"\nExpected |Pa| = p^d = {int(p)}^{d} = {int(p)^d:.2e}")
print(f"Empirical (valid pairs found): {pa_count}/{N}")
print(f"Ratio                        : {float(pa_count)/float(N):.6f}")
print(f"Expected ratio (1/p^d * p^d samples): ~1.0 jika sample dari Pa")
