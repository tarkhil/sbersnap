module.exports = {
  configureWebpack: {
    devServer: {
      watchOptions: {
        ignored: ["/node_modules/", "**/.#*"]
      }
    }
  },
  parallel: true,
  devServer: {
    disableHostCheck: true,
    public: process.env.DEV_PUBLIC ?? "snap.over.ru",
    port: process.env.DEV_PORT ?? 8085
  }
};
