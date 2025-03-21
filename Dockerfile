FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    tzdata \
    fonts-dejavu \
    fonts-liberation \
    fonts-noto \
    fonts-noto-cjk \
    fonts-noto-color-emoji \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Google Chrome
#RUN mkdir -p /usr/share/keyrings \
#    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg && \
#    sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' && \
#    apt-get update && \
#    apt-get install -y google-chrome-stable --no-install-recommends && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/*

# 添加 Google Chrome 的 GPG 密钥
RUN mkdir -p /usr/share/keyrings \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor > /usr/share/keyrings/google-chrome.gpg

# 添加 Google Chrome 的存储库
RUN sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list'

# 更新包列表并安装 Google Chrome
RUN apt-get update && apt-get install -y google-chrome-stable --no-install-recommends && apt-get clean && rm -rf /var/lib/apt/lists/*


# 设置时区
ENV TZ=Asia/Shanghai

COPY . .

RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ && \
    chmod +x images

ENV PORT=8080

EXPOSE $PORT

CMD ["sh", "-c", "python main.py"]