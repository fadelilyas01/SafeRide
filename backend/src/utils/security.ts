import {
  createHash,
  createHmac,
  randomBytes,
  randomInt,
  scryptSync,
  timingSafeEqual,
} from "crypto";

interface RateLimitRecord {
  attempts: number;
  lockedUntil: number;
  windowStart: number;
}

const rateLimitStore = new Map<string, RateLimitRecord>();
const runtimeSessionKey =
  process.env.SESSION_SECRET || randomBytes(32).toString("hex");

/**
 * Genere un code PIN a 4 chiffres avec un generateur cryptographique CSPRNG (CWE-338).
 */
export function generateSecurePin(): string {
  return randomInt(1000, 10000).toString();
}

/**
 * Compare deux codes PIN ou secrets en temps constant pour eliminer les attaques temporelles (CWE-208).
 */
export function constantTimePinCompare(
  expected: string,
  actual: string
): boolean {
  const expectedDigest = createHash("sha256").update(expected, "utf8").digest();
  const actualDigest = createHash("sha256").update(actual, "utf8").digest();
  return (
    timingSafeEqual(expectedDigest, actualDigest) &&
    expected.length === actual.length
  );
}

/**
 * Hache un mot de passe utilisateur avec scrypt et un sel CSPRNG de 16 octets.
 */
export function hashPassword(password: string): string {
  const salt = randomBytes(16).toString("hex");
  const derivedKey = scryptSync(password, salt, 64).toString("hex");
  return `${salt}:${derivedKey}`;
}

/**
 * Verifie un mot de passe par rapport au hash stocke en temps constant (CWE-208).
 */
export function verifyPassword(password: string, storedHash: string): boolean {
  const parts = storedHash.split(":");
  if (parts.length !== 2) return false;
  const [salt, keyHex] = parts;
  const keyBuffer = Buffer.from(keyHex, "hex");
  const derivedBuffer = scryptSync(password, salt, 64);
  if (keyBuffer.length !== derivedBuffer.length) return false;
  return timingSafeEqual(keyBuffer, derivedBuffer);
}

/**
 * Génère un jeton de session signé par HMAC-SHA256 à courte durée de vie (15 minutes).
 */
export function createSignedSessionToken(payload: {
  userId: string;
  role: string;
}): string {
  const exp = Date.now() + 15 * 60 * 1000;
  const data = Buffer.from(
    JSON.stringify({ userId: payload.userId, role: payload.role, exp }),
    "utf8"
  ).toString("base64url");
  const signature = createHmac("sha256", runtimeSessionKey)
    .update(data)
    .digest("base64url");
  return `${data}.${signature}`;
}

/**
 * Controle et applique une limite de tentatives anti-force brute avec verrouillage temporise.
 */
export function verifyRateLimit(
  key: string,
  maxAttempts: number = 3,
  lockDurationMs: number = 5 * 60 * 1000,
  windowMs: number = 10 * 60 * 1000
): { allowed: boolean; remainingAttempts: number; retryAfterSeconds: number } {
  const now = Date.now();
  const current = rateLimitStore.get(key);

  if (current) {
    if (current.lockedUntil > now) {
      return {
        allowed: false,
        remainingAttempts: 0,
        retryAfterSeconds: Math.ceil((current.lockedUntil - now) / 1000),
      };
    }

    if (now - current.windowStart > windowMs) {
      rateLimitStore.delete(key);
    }
  }

  const record = rateLimitStore.get(key);
  const attemptsUsed = record ? record.attempts : 0;

  return {
    allowed: true,
    remainingAttempts: Math.max(0, maxAttempts - attemptsUsed),
    retryAfterSeconds: 0,
  };
}

/**
 * Enregistre un echec d'authentification ou de validation de code PIN et active le verrouillage si le seuil est atteint.
 */
export function recordFailedAttempt(
  key: string,
  maxAttempts: number = 3,
  lockDurationMs: number = 5 * 60 * 1000,
  windowMs: number = 10 * 60 * 1000
): { locked: boolean; remainingAttempts: number; retryAfterSeconds: number } {
  const now = Date.now();
  const existing = rateLimitStore.get(key);

  const isExpiredWindow = !existing || now - existing.windowStart > windowMs;
  const attempts = isExpiredWindow ? 1 : existing.attempts + 1;
  const windowStart = isExpiredWindow ? now : existing.windowStart;
  const lockedUntil = attempts >= maxAttempts ? now + lockDurationMs : 0;

  rateLimitStore.set(key, {
    attempts,
    windowStart,
    lockedUntil,
  });

  return {
    locked: lockedUntil > now,
    remainingAttempts: Math.max(0, maxAttempts - attempts),
    retryAfterSeconds: lockedUntil > now ? Math.ceil(lockDurationMs / 1000) : 0,
  };
}

/**
 * Reinitialise le compteur de tentatives apres une validation reussie.
 */
export function clearRateLimit(key: string): void {
  rateLimitStore.delete(key);
}

/**
 * Calcule une empreinte d'integrite SHA-256 canonique sur un objet de donnees (CWE-345).
 */
export function computeCanonicalSha256(
  payload: Record<string, unknown>
): string {
  const sortedKeys = Object.keys(payload).sort();
  const canonicalObject: Record<string, unknown> = {};
  for (const key of sortedKeys) {
    canonicalObject[key] = payload[key];
  }
  const serialized = JSON.stringify(canonicalObject);
  return createHash("sha256").update(serialized, "utf8").digest("hex");
}
