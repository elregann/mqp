import secrets

p  = next_prime(2^32)
Zp = Integers(p)
d  = 4
R  = PolynomialRing(Zp, 'X')
X  = R.gen()
QR = R.quotient(X^d - 1, 'x')

# KEM MQP: sama strukturnya dengan QP biasa
# tapi semua operasi di ring R_Q

# Shared random r (publik)
r  = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])

# Alice dan Bob generate secret
xA = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])
xB = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])

# Public values
aA = xA * r
aB = xB * r

# Shared key
skA = xA * aB   # = xA * xB * r
skB = xB * aA   # = xB * xA * r

print(f"skA = {skA}")
print(f"skB = {skB}")
print(f"Match: {skA == skB}")
