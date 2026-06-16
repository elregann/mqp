import secrets
import time

p  = next_prime(2^32)
Zp = Integers(p)
d  = 4
R  = PolynomialRing(Zp, 'X')
X  = R.gen()
QR = R.quotient(X^d - 1, 'x')

N = 1000

# ─────────────────────────────────────
# QP biasa
# ─────────────────────────────────────
t0 = time.time()
for _ in range(N):
    r  = Zp(secrets.randbelow(int(p-1)) + 1)
    xA = Zp(secrets.randbelow(int(p-1)) + 1)
    xB = Zp(secrets.randbelow(int(p-1)) + 1)
    aA = xA * r
    aB = xB * r
    skA = xA * aB
    skB = xB * aA
t_qp = float(time.time() - t0) / float(N)

# ─────────────────────────────────────
# MQP
# ─────────────────────────────────────
t0 = time.time()
for _ in range(N):
    r  = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    xA = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    xB = QR([Zp(secrets.randbelow(int(p))) for _ in range(d)])
    aA = xA * r
    aB = xB * r
    skA = xA * aB
    skB = xB * aA
t_mqp = float(time.time() - t0) / float(N)

print("=" * 55)
print("PERBANDINGAN KEM QP vs MQP")
print("=" * 55)

print(f"\n  QP biasa:")
print(f"    |Pa|      = p     = {int(p):.2e}")
print(f"    Security  = {int(p).bit_length()} bits")
print(f"    Time/op   = {float(t_qp)*1000:.4f} ms")

print(f"\n  MQP (d={d}):")
print(f"    |Pa|      = p^d   = {int(p)^int(d):.2e}")
print(f"    Security  = {int(d) * int(p).bit_length()} bits")
print(f"    Time/op   = {float(t_mqp)*1000:.4f} ms")

ratio_sec  = float(int(d) * int(p).bit_length()) / float(int(p).bit_length())
ratio_time = float(t_mqp) / float(t_qp)

print(f"\n  Security gain : {float(ratio_sec):.1f}x")
print(f"  Time overhead : {float(ratio_time):.2f}x")
print(f"  Efisiensi     : {float(ratio_sec)/float(ratio_time):.2f}x security per unit time")
print("=" * 55)
