import atexit
import base64
import glob
import os
import time

from DrissionPage import ChromiumPage, ChromiumOptions
from apscheduler.schedulers.background import BackgroundScheduler
from flask import Flask, jsonify, request, send_file

app = Flask(__name__)

scheduler = BackgroundScheduler()


def scheduled_task():
    # 构建搜索模式
    search_pattern = os.path.join('images', '*.png')
    # 获取所有匹配的文件
    png_files = glob.glob(search_pattern)
    for file_path in png_files:
        try:
            os.remove(file_path)
        except Exception as e:
            print(f"Failed to delete {file_path}: {e}")


# 添加定时任务 (每天上午10点运行任务)
scheduler.add_job(func=scheduled_task, trigger="cron", hour=10, minute=0)
scheduler.start()
# 确保在程序退出时关闭调度器
atexit.register(lambda: scheduler.shutdown())


def json(code, msg, data=''):
    return jsonify({
        'code': code,
        'msg': msg,
        'data': data
    })


def url_to_img(url: str, filename: str, elements: str = None):
    co = ChromiumOptions()
    co.set_paths(browser_path=r'/usr/bin/google-chrome')
    co.set_argument('--no-sandbox')  # 无沙盒模式
    co.set_argument('--headless=new')  # 无头
    # co.set_argument('--remote-debugging-port=9300')  # 端口设置
    co.set_argument('--disable-gpu')  # 无gpu
    co.set_argument('--start-maximized') # 设置启动时最大化
    # co.set_local_port("9300")
    co.set_timeouts(base=5)
    try:
        page = ChromiumPage(co)
        page.clear_cache()
        page.get(url, retry=3, timeout=5)
        if elements:
            page.ele(elements).get_screenshot(f'./images/{filename}')
        else:
            page.get_screenshot(f'./images/{filename}')

        page.quit() # 关闭浏览器。
        page.close() # 关闭连接。
        return ''
    except Exception as e:
        return e


@app.route('/')
def index():
    return json(200, 'Welcome to url2img')


@app.route('/api/img')
def img():
    url = request.args.get('url')
    if not url:
        return json(500, 'invalid url')

    filename = f"{time.time()}.png"
    result = url_to_img(url, filename, request.args.get('elements', ''))

    if not os.path.exists(f'./images/{filename}'):
        return json(500, f'生成图片失败，请确保 url/elements 无误，{result}')

    return send_file(f'./images/{filename}', mimetype='image/png')


@app.route('/api/img/base64')
def img_base64():
    url = request.args.get('url')
    if not url:
        return json(500, 'invalid url')

    filename = f"{time.time()}.png"
    result = url_to_img(url, filename, request.args.get('elements', ''))

    if not os.path.exists(f'./images/{filename}'):
        return json(500, f'生成图片失败，请确保 url/elements 无误，{result}')

    imgBase64 = base64.b64encode(open(f"./images/{filename}", 'rb').read()).decode()
    return json(200, 'ok', f"data:image/png;base64,{imgBase64}")


@app.errorhandler(404)
def page_not_found(e):
    return json(404, f'route [{request.path}] not found')


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=8080)
