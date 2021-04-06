const envs = ["development", "staging", "production"].reduce(
  (memo, env) => ({
    ...memo,
    [env]: {
      region: process.env[`${env.toUpperCase()}_AWS_REGION`],
      accessKeyId: process.env[`${env.toUpperCase()}_AWS_ACCESS_KEY_ID`],
      secretAccessKey: process.env[`${env.toUpperCase()}_AWS_SECRET_ACCESS_KEY`],
    },
  }),
  {},
);

export const awsConfig = (env = "") => {
  const config = envs[(env.trim() || "production").toLowerCase()];
  if (config) return config;
  throw new Error(`Unknown environment ${env}`);
};
