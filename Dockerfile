FROM python:3.12.9-alpine3.21

WORKDIR /app

# 安装必要的依赖和 Chromium 浏览器
RUN apk update && apk add --no-cache \
    bash \
    curl \
    gcc \
    g++ \
    make \
    libc-dev \
    linux-headers \
    chromium \
    nss \
    freetype \
    harfbuzz \
    fontconfig \
    ttf-dejavu \
    ttf-liberation \
    ttf-freefont \
    font-noto \
    font-noto-cjk \
    font-noto-emoji \
    tzdata

# 刷新字体缓存
RUN fc-cache -f -v

# 设置时区为上海
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 设置环境变量
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_PATH=/usr/lib/chromium/

# 确保 Chromium 浏览器可执行
RUN ln -sf /usr/bin/chromium-browser /usr/bin/google-chrome

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ && \
    chmod +x images

EXPOSE 8080

CMD ["sh", "-c", "python main.py"]