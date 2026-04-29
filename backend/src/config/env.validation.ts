type RawEnv = Record<string, string | undefined>;

const REQUIRED_ENV_KEYS = ['DATABASE_URL', 'AUTH_ACCESS_TOKEN_SECRET'] as const;

export function validateEnv(config: RawEnv) {
  for (const key of REQUIRED_ENV_KEYS) {
    if (!config[key]) {
      throw new Error(`Missing required environment variable: ${key}`);
    }
  }

  const port = Number(config.PORT ?? 3000);
  if (!Number.isInteger(port) || port <= 0) {
    throw new Error('PORT must be a positive integer');
  }

  const refreshTokenTtlDays = Number(config.AUTH_REFRESH_TOKEN_TTL_DAYS ?? 30);
  if (!Number.isInteger(refreshTokenTtlDays) || refreshTokenTtlDays <= 0) {
    throw new Error('AUTH_REFRESH_TOKEN_TTL_DAYS must be a positive integer');
  }

  const resetTokenTtlMinutes = Number(
    config.AUTH_PASSWORD_RESET_TOKEN_TTL_MINUTES ?? 30,
  );
  if (!Number.isInteger(resetTokenTtlMinutes) || resetTokenTtlMinutes <= 0) {
    throw new Error(
      'AUTH_PASSWORD_RESET_TOKEN_TTL_MINUTES must be a positive integer',
    );
  }

  const saltRounds = Number(config.AUTH_PASSWORD_SALT_ROUNDS ?? 12);
  if (!Number.isInteger(saltRounds) || saltRounds < 10) {
    throw new Error('AUTH_PASSWORD_SALT_ROUNDS must be an integer >= 10');
  }

  const invitePublicBaseUrl = config.INVITE_PUBLIC_BASE_URL?.trim();
  if (invitePublicBaseUrl) {
    try {
      const url = new URL(invitePublicBaseUrl);
      if (url.protocol !== 'https:' && url.protocol !== 'http:') {
        throw new Error('Invalid protocol');
      }
    } catch {
      throw new Error('INVITE_PUBLIC_BASE_URL must be a valid URL');
    }
  }

  return {
    ...config,
    PORT: String(port),
    NODE_ENV: config.NODE_ENV ?? 'development',
    AUTH_REFRESH_TOKEN_TTL_DAYS: String(refreshTokenTtlDays),
    AUTH_PASSWORD_RESET_TOKEN_TTL_MINUTES: String(resetTokenTtlMinutes),
    AUTH_PASSWORD_SALT_ROUNDS: String(saltRounds),
  };
}
