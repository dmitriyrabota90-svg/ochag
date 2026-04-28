export default () => ({
  app: {
    nodeEnv: process.env.NODE_ENV ?? 'development',
    port: Number(process.env.PORT ?? 3000),
  },
  auth: {
    accessTokenSecret: process.env.AUTH_ACCESS_TOKEN_SECRET,
    accessTokenTtl: process.env.AUTH_ACCESS_TOKEN_TTL ?? '15m',
    refreshTokenTtlDays: Number(process.env.AUTH_REFRESH_TOKEN_TTL_DAYS ?? 30),
    passwordResetTokenTtlMinutes: Number(
      process.env.AUTH_PASSWORD_RESET_TOKEN_TTL_MINUTES ?? 30,
    ),
    passwordSaltRounds: Number(process.env.AUTH_PASSWORD_SALT_ROUNDS ?? 12),
    appBaseUrl: process.env.APP_BASE_URL ?? 'http://localhost:3000',
  },
  database: {
    url: process.env.DATABASE_URL,
  },
});
