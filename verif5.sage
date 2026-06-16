import secrets

p  = next_prime(2^32)
Zp = Integers(p)

# KEM QP yang benar:
# Alice: secret xA, public aA = xA * rA (rA random)
# Bob:   secret xB, public aB = xB * rB (rB random)
# Shared: xA * aB = xA * xB * rB
#         xB * aA = xB * xA * rA
# Ini masih tidak sama kecuali rA = rB!
#
# Yang benar dari paper: SATU shared random r
# Alice: aA = xA * r
# Bob:   aB = xB * r
# Shared: xB * aA = xA * aB = xA * xB * r

r  = Zp(secrets.randbelow(int(p-1)) + 1)  # shared random (publik)
xA = Zp(secrets.randbelow(int(p-1)) + 1)
xB = Zp(secrets.randbelow(int(p-1)) + 1)

aA = xA * r   # Alice publik
aB = xB * r   # Bob publik

skA = xA * aB  # = xA * xB * r
skB = xB * aA  # = xB * xA * r

print(f"skA = {int(skA)}")
print(f"skB = {int(skB)}")
print(f"Match: {skA == skB}")
