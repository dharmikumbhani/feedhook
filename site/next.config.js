/** @type {import('next').NextConfig} */
const nextConfig = {
  // experimental: {
  //   appDir: true,
  //   serverComponentsExternalPackages: ['@tremor/react'],
  // },
  reactStrictMode: true,
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'tailwindui.com',
        port: '',
        pathname: '/*',
      },
    ],
  },
}

module.exports = nextConfig
