/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  images: {
    domains: [process.env.CLOUDFRONT_DOMAIN || 'localhost'],
  },
};

module.exports = nextConfig;
