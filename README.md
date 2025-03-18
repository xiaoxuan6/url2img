# url2img

url转图片

# 请求参数

| 字段       | 解释         | 是否必填 |
|:---------|:-----------|:-----|
| url      | 需要转图片的链接地址 | 是    |
| elements | 元素属性       | 否    |

## elements

元素属性（class、id、css、xpath）,更多属性 [定位语法](https://www.drissionpage.cn/browser_control/get_elements/syntax)

### class

```
elements='.p_cls'
```

### id

```js
elements = '#one'
```

### css

```js
elements = 'css:.dev'
```

### xpath

```js
elements = 'xpath:.//div'
```

# Demo

## 生成图片（直接返回图片）

```curl
http://127.0.0.1:8080/api/img?url=https://www.drissionpage.cn/browser_control/browser_options/
```

## 生成图片（base64）

> 在线 [base64img](https://www.kgtools.cn/convert/base64img) 转图片

```curl
http://127.0.0.1:8080/api/img/base64?url=https://www.drissionpage.cn/browser_control/browser_options/
```

# Docker

（默认）端口

```docker
docker run --name url2img -p 8080:8080 -d ghcr.io/xiaoxuan6/url2img:v1.1.0
```

自定义端口

```docker
docker run --name url2img -p 9990:9990 -e PORT=9990 -d ghcr.io/xiaoxuan6/url2img:v1.1.0
```