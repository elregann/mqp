import secrets
import hashlib
import time

# ─────────────────────────────────────────────────────
# TARGET: 128-bit security untuk KEDUANYA
#
# QP biasa: |Pa| = p → butuh p ≈ 2^128
# MQP d=4:  |Pa| = p^4 → cukup p ≈ 2^32
# ─────────────────────────────────────────────────────

# QP biasa: p besar untuk 128-bit security
p_qp = next_prime(2^128)
Zp_qp = Integers(p_qp)

# MQP: p kecil, d=4, total security = 4*32 = 128 bits
p_mqp = next_prime(2^32)
d     = 4
Zp_mqp = Integers(p_mqp)
R      = PolynomialRing(Zp_mqp, 'X')
X      = R.gen()
QR     = R.quotient(X^d - 1, 'x')

print(f"TARGET: 128-bit security")
print(f"QP  : p = next_prime(2^128) ≈ {float(p_qp):.2e}")
print(f"MQP : p = next_prime(2^32)  ≈ {float(p_mqp):.2e}, d={d}")
print(f"QP  security: {int(p_qp).bit_length()} bits")
print(f"MQP security: {int(d) * int(p_mqp).bit_length()} bits")

# ─────────────────────────────────────
# KEM QP BIASA (p besar, 128-bit)
# ─────────────────────────────────────
def qp_keygen():
    r  = Zp_qp(secrets.randbelow(int(p_qp-1)) + 1)
    xA = Zp_qp(secrets.randbelow(int(p_qp-1)) + 1)
    xB = Zp_qp(secrets.randbelow(int(p_qp-1)) + 1)
    aA = xA * r
    aB = xB * r
    return (xA, xB, r), (aA, aB)

def qp_shared(xA, aB):
    return xA * aB

# ─────────────────────────────────────
# KEM MQP (p kecil, d=4, 128-bit)
# ─────────────────────────────────────
def mqp_keygen():
    r  = QR([Zp_mqp(secrets.randbelow(int(p_mqp))) for _ in range(d)])
    xA = QR([Zp_mqp(secrets.randbelow(int(p_mqp))) for _ in range(d)])
    xB = QR([Zp_mqp(secrets.randbelow(int(p_mqp))) for _ in range(d)])
    aA = xA * r
    aB = xB * r
    return (xA, xB, r), (aA, aB)

def mqp_shared(xA, aB):
    return xA * aB

# ═══════════════════════════════════════
# TEST 1: CORRECTNESS
# ═══════════════════════════════════════
print("\n" + "=" * 55)
print("TEST 1: CORRECTNESS")
print("=" * 55)

# QP
(xA_q, xB_q, r_q), (aA_q, aB_q) = qp_keygen()
skA_qp = qp_shared(xA_q, aB_q)
skB_qp = qp_shared(xB_q, aA_q)
print(f"\n[QP biasa, p≈2^128]")
print(f"  skA == skB : {skA_qp == skB_qp}")

# MQP
(xA_m, xB_m, r_m), (aA_m, aB_m) = mqp_keygen()
skA_mqp = mqp_shared(xA_m, aB_m)
skB_mqp = mqp_shared(xB_m, aA_m)
print(f"\n[MQP, p≈2^32, d=4]")
print(f"  skA == skB : {skA_mqp == skB_mqp}")

# ═══════════════════════════════════════
# TEST 2: EFISIENSI (fair comparison)
# ═══════════════════════════════════════
print("\n" + "=" * 55)
print("TEST 2: EFISIENSI (128-bit security keduanya)")
print("=" * 55)

N = 100

# QP biasa (p besar)
t0 = time.time()
for _ in range(N):
    (xA_, xB_, r_), (aA_, aB_) = qp_keygen()
    _ = qp_shared(xA_, aB_)
t_qp = float(time.time() - t0) / float(N)

# MQP (p kecil, d=4)
t0 = time.time()
for _ in range(N):
    (xA_, xB_, r_), (aA_, aB_) = mqp_keygen()
    _ = mqp_shared(xA_, aB_)
t_mqp = float(time.time() - t0) / float(N)

print(f"\n  QP biasa (p≈2^128):")
print(f"    |Pa|       = p     ≈ {float(p_qp):.2e}")
print(f"    Security   = {int(p_qp).bit_length()} bits")
print(f"    Key size   = {int(p_qp).bit_length()} bits per element")
print(f"    Time/op    = {float(t_qp)*1000:.4f} ms")

print(f"\n  MQP (p≈2^32, d=4):")
print(f"    |Pa|       = p^d   ≈ {float(p_mqp)^float(d):.2e}")
print(f"    Security   = {int(d) * int(p_mqp).bit_length()} bits")
print(f"    Key size   = {int(d) * int(p_mqp).bit_length()} bits per element (d koefisien)")
print(f"    Time/op    = {float(t_mqp)*1000:.4f} ms")

print(f"\n  Speedup MQP vs QP: {float(t_qp)/float(t_mqp):.2f}x lebih cepat")
print(f"  Key size sama    : {int(p_qp).bit_length()} vs {int(d)*int(p_mqp).bit_length()} bits")

print("\n" + "=" * 55)
print("RINGKASAN")
print("=" * 55)
print(f"  QP  Correctness : {skA_qp == skB_qp}")
print(f"  MQP Correctness : {skA_mqp == skB_mqp}")
print(f"  MQP lebih cepat : {float(t_qp)/float(t_mqp):.2f}x")
print(f"  Security setara : {int(p_qp).bit_length()} ≈ {int(d)*int(p_mqp).bit_length()} bits")
