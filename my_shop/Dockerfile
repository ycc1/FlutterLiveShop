# 使用轻量版 Nginx 作为基础镜像
FROM nginx:alpine

# 作者信息（可选）
LABEL maintainer="yourname@example.com"

# 删除默认 Nginx 静态页
RUN rm -rf /usr/share/nginx/html/*

# 拷贝 Flutter 打包好的网页
COPY build/web /usr/share/nginx/html

# 拷贝自定义 Nginx 配置（支持前端路由）
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 8099

# 启动 Nginx
CMD ["nginx", "-g", "daemon off;"]
