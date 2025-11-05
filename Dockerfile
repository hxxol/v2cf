FROM debian:stable-slim

ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget unzip bash tzdata gnupg apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制 v2ray 配置
COPY config.json /etc/v2ray/config.json

# 安装 v2ray
RUN mkdir -p /var/log/v2ray /usr/share/v2ray /usr/bin \
    && wget -O /tmp/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip \
    && unzip -j /tmp/v2ray.zip -d /usr/bin v2ray \
    && chmod +x /usr/bin/v2ray \
    && wget -O /usr/share/v2ray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat || true \
    && wget -O /usr/share/v2ray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat || true \
    && rm -f /tmp/v2ray.zip

# 安装 cloudflared
RUN mkdir -p /usr/share/keyrings \
    && curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main' \
         | tee /etc/apt/sources.list.d/cloudflared.list \
    && apt-get update && apt-get install -y cloudflared \
    && rm -rf /var/lib/apt/lists/*

# 复制入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1988

WORKDIR /root
CMD ["/entrypoint.sh"]
