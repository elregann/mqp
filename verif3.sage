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

x_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
y_true = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
a      = f_mqp(x_true, y_true)

print(f"p={int(p)}, d={d}")
print(f"a = {a}")

# ───────────────────────────────────────────────
# Attack 1: Factorization attack
# X^d - 1 = (X-1)(X^{d-1} + ... + 1) di Zp[X]
# Apakah adversary bisa factor a dan recover (x,y)?
# ───────────────────────────────────────────────
print("\n=== ATTACK 1: FACTORIZATION VIA RING STRUCTURE ===")

# Factor X^d - 1 di Zp
poly    = X^d - 1
factors = poly.factor()
print(f"  X^d - 1 factors: {factors}")

# Apakah a bisa di-factor untuk recover x atau y?
a_lift  = a.lift()
a_factors = a_lift.factor()
print(f"  a factors in Zp[X]: {a_factors}")
print(f"  Adversary bisa recover (x,y) dari factor a? ", end="")

# Cek: apakah faktor a memberikan info tentang x_true atau y_true
x_lift = x_true.lift()
y_lift = y_true.lift()
x_factors = x_lift.factor() if x_lift != 0 else "zero"
print(f"Need to check manually")
print(f"  x_true factors: {x_factors}")
print(f"  y_true factors: {y_lift.factor() if y_lift != 0 else 'zero'}")

# ───────────────────────────────────────────────
# Attack 2: Zero divisor attack
# Di ring X^d-1, ada zero divisors
# Apakah adversary bisa eksploitasi ini?
# ───────────────────────────────────────────────
print("\n=== ATTACK 2: ZERO DIVISOR ATTACK ===")

# Zero divisors di X^3-1: elemen yang non-invertible
# X^3-1 = (X-1)(X^2+X+1) → elemen yang berbagi faktor
zero_divs = []
for _ in range(1000):
    z = Q([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    try:
        _ = Q(1) / z
    except:
        zero_divs.append(z)

print(f"  Zero divisors found (1000 samples): {len(zero_divs)}")
print(f"  Prob zero divisor: {float(len(zero_divs))/float(1000):.4f}")

# Apakah x_true adalah zero divisor?
x_is_zero_div = False
try:
    _ = Q(1) / x_true
except:
    x_is_zero_div = True
print(f"  x_true is zero divisor: {x_is_zero_div}")

# ───────────────────────────────────────────────
# Attack 3: CRT attack
# X^3-1 = (X-1)(X^2+X+1) over Zp
# Via CRT: R_Q ≅ Zp × Zp[X]/(X^2+X+1)
# Apakah a bisa di-decompose via CRT dan leak info?
# ───────────────────────────────────────────────
print("\n=== ATTACK 3: CRT DECOMPOSITION ===")

# Evaluasi a di X=1 (komponen CRT pertama)
a_at_1 = sum(int(c) for c in a.lift().coefficients(sparse=False)) % int(p)
x_at_1 = sum(int(c) for c in x_true.lift().coefficients(sparse=False)) % int(p)
y_at_1 = sum(int(c) for c in y_true.lift().coefficients(sparse=False)) % int(p)

print(f"  a(1) = {a_at_1}")
print(f"  x*(1) = {x_at_1}")
print(f"  y*(1) = {y_at_1}")
print(f"  x*(1) * y*(1) mod p = {(x_at_1 * y_at_1) % int(p)}")
print(f"  = a(1)? {(x_at_1 * y_at_1) % int(p) == a_at_1}")
print(f"  → a(1) = x(1)*y(1): ini Q-IND di Zp (scalar)")
print(f"  → Adversary tahu a(1) tapi tidak bisa recover x(1) atau y(1)")
print(f"    karena ini Q1nI (|Pa_scalar| = p)")

# ───────────────────────────────────────────────
# RINGKASAN
# ───────────────────────────────────────────────
print("\n=== RINGKASAN ATTACK ANALYSIS ===")
print(f"  Attack 1 (factorization) : perlu analisis manual")
print(f"  Attack 2 (zero divisor)  : prob={float(len(zero_divs))/float(1000):.4f}, x_true safe={not x_is_zero_div}")
print(f"  Attack 3 (CRT)           : leak a(1)=x(1)*y(1), tapi tetap Q1nI")
