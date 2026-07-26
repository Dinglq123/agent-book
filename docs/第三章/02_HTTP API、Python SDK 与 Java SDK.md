---
title: "HTTP API、Python SDK 与 Java SDK"
site: "智谱AI开放文档"
sources:
  - "https://docs.bigmodel.cn/cn/guide/develop/http/introduction"
  - "https://docs.bigmodel.cn/cn/guide/develop/python/introduction"
  - "https://docs.bigmodel.cn/cn/guide/develop/java/introduction"
coverImage: "imgs/02-develop-cover-01.png"
capturedAt: "2026-07-26T05:25:01.094Z"
---

# HTTP API、Python SDK 与 Java SDK

## HTTP API 调用

### 获取 API Key

1. 访问 [智谱开放平台](https://bigmodel.cn/)
2. 注册并登录您的账户
3. 在 [API Keys](https://bigmodel.cn/usercenter/proj-mgmt/apikeys) 管理页面创建 API Key
4. 复制您的 API Key 以供使用

![创建 API Key](../imgs/02-api-key-create.png)

建议将 API Key 设置为环境变量替代硬编码到代码中，以提高安全性。

### API 基础信息

#### 请求端点(通用API)

```
https://open.bigmodel.cn/api/paas/v4/
```

#### 请求头要求

```
Content-Type: application/json
Authorization: Bearer YOUR_API_KEY
```

#### 支持的鉴权方式

- API Key 鉴权

最简单的鉴权方式，直接使用您的 API Key：

```
curl --location 'https://open.bigmodel.cn/api/paas/v4/chat/completions' \
--header 'Authorization: Bearer YOUR_API_KEY' \
--header 'Content-Type: application/json' \
--data '{
    "model": "glm-5.2",
    "messages": [
        {
            "role": "user",
            "content": "你好"
        }
    ]
}'
```

- JWT Token 鉴权

使用 JWT Token 进行鉴权，适合需要更高安全性的场景： 安装依赖 PyJWT

```
pip install PyJWT
```

```
import time
import jwt

def generate_token(apikey: str, exp_seconds: int):
    try:
        id, secret = apikey.split(".")
    except Exception as e:
        raise Exception("invalid apikey", e)

    payload = {
        "api_key": id,
        "exp": int(round(time.time() * 1000)) + exp_seconds * 1000,
        "timestamp": int(round(time.time() * 1000)),
    }

    return jwt.encode(
        payload,
        secret,
        algorithm="HS256",
        headers={"alg": "HS256", "sign_type": "SIGN"},
    )

# 使用生成的 token
token = generate_token("YOUR_API_KEY", 3600)  # 1 小时有效期
```

### 基础调用示例

#### 简单对话

```
curl --location 'https://open.bigmodel.cn/api/paas/v4/chat/completions' \
--header 'Authorization: Bearer YOUR_API_KEY' \
--header 'Content-Type: application/json' \
--data '{
    "model": "glm-5.2",
    "messages": [
        {
            "role": "user",
            "content": "请介绍一下人工智能的发展历程"
        }
    ],
    "temperature": 1.0,
    "max_tokens": 1024
}'
```

#### 流式响应

```
curl --location 'https://open.bigmodel.cn/api/paas/v4/chat/completions' \
--header 'Authorization: Bearer YOUR_API_KEY' \
--header 'Content-Type: application/json' \
--data '{
    "model": "glm-5.2",
    "messages": [
        {
            "role": "user",
            "content": "写一首关于春天的诗"
        }
    ],
    "stream": true
}'
```

#### 多轮对话

```
curl --location 'https://open.bigmodel.cn/api/paas/v4/chat/completions' \
--header 'Authorization: Bearer YOUR_API_KEY' \
--header 'Content-Type: application/json' \
--data '{
    "model": "glm-5.2",
    "messages": [
        {
            "role": "system",
            "content": "你是一个专业的编程助手"
        },
        {
            "role": "user",
            "content": "什么是递归？"
        },
        {
            "role": "assistant",
            "content": "递归是一种编程技术，函数调用自身来解决问题..."
        },
        {
            "role": "user",
            "content": "能给我一个 Python 递归的例子吗？"
        }
    ]
}'
```

### 编程示例

- Python

```
import requests
import json

def call_zhipu_api(messages, model="glm-5.2"):
    url = "https://open.bigmodel.cn/api/paas/v4/chat/completions"

    headers = {
        "Authorization": "Bearer YOUR_API_KEY",
        "Content-Type": "application/json"
    }

    data = {
        "model": model,
        "messages": messages,
        "temperature": 1.0
    }

    response = requests.post(url, headers=headers, json=data)

    if response.status_code == 200:
        return response.json()
    else:
        raise Exception(f"API调用失败: {response.status_code}, {response.text}")

# 使用示例
messages = [
    {"role": "user", "content": "你好，请介绍一下自己"}
]

result = call_zhipu_api(messages)
print(result['choices'][0]['message']['content'])
```


- Java

```
import com.fasterxml.jackson.databind.ObjectMapper;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class AgentExample {

    public static void main(String[] args) throws Exception {

        OkHttpClient client = new OkHttpClient();
        ObjectMapper mapper = new ObjectMapper();
        Map<String, String> messages = new HashMap<>(8);
        messages.put("role", "user");
        messages.put("content", "你好，请介绍一下自己");
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("model", "glm-5.2");
        requestBody.put("messages", Collections.singletonList(messages));
        requestBody.put("temperature", 1.0);

        String jsonBody = mapper.writeValueAsString(requestBody);
        MediaType JSON = MediaType.get("application/json; charset=utf-8");
        RequestBody body = RequestBody.create(JSON, jsonBody);
        Request request = new Request.Builder()
            .url("https://open.bigmodel.cn/api/paas/v4/chat/completions")
            .addHeader("Authorization", "Bearer YOUR_API_KEY")
            .addHeader("Content-Type", "application/json")
            .post(body)
            .build();
        try (Response response = client.newCall(request).execute()) {
            System.out.println(response.body().string());
        }
    }
}
```

### 错误处理

#### 常见错误码

| 错误码 | 说明 | 解决方案 |
| --- | --- | --- |
| 401 | 未授权 | 检查 API Key 是否正确 |
| 429 | 请求过于频繁 | 降低请求频率，实施重试机制 |
| 500 | 服务器内部错误 | 稍后重试，如持续出现请联系支持 |

更多错误码和解决方案请参考 [API 错误码文档](https://docs.bigmodel.cn/cn/faq/api-code)

### 实践建议

### 安全性

- 妥善保管 API Key，不要在代码中硬编码
- 使用环境变量或配置文件存储敏感信息
- 定期轮换 API Key

### 性能优化

- 实施连接池和会话复用
- 合理设置超时时间
- 使用异步请求处理高并发场景

### 错误处理

- 实施指数退避重试机制
- 记录详细的错误日志
- 设置合理的超时和重试次数

### 监控

- 监控 API 调用频率和成功率
- 跟踪响应时间和错误率
- 设置告警机制


---

## 官方 Python SDK

来源：https://docs.bigmodel.cn/cn/guide/develop/python/introduction

Python SDK 是一个智谱提供的功能强大、易于使用的 Python 开发工具包，专为与智谱的各种人工智能模型进行交互而设计，为 Python 开发者提供便捷、高效的 AI 模型集成方案。

#### 支持的功能

- **对话聊天** ：支持单轮和多轮对话，流式和非流式响应
- **函数调用** ：让 AI 模型调用您的自定义函数
- **视觉理解** ：图像分析、视觉问答
- **图像生成** ：根据文本描述生成高质量图像
- **视频生成** ：文本到视频的创意内容生成
- **语音处理** ：语音转文字、文字转语音
- **文本嵌入** ：文本向量化，支持语义搜索
- **智能助手** ：构建专业的 AI 助手应用
- **内容审核** ：文本和图像内容安全检测

### 技术规格

#### 环境要求

- Python 版本 ：Python 3.8 或更高版本
- 包管理器 ：pip 或 poetry
- 网络要求 ：支持 HTTPS 连接
- API 密钥 ：需要有效的智谱 API 密钥

#### 依赖管理

SDK 采用模块化设计，您可以根据需要选择性安装功能模块：

- **核心模块** ：基础 API 调用功能
- **异步模块** ：异步和并发处理支持
- **工具模块** ：实用工具和辅助功能

### 快速开始

#### 安装 SDK

##### 使用 pip 安装

```bash
# 安装最新版本
pip install zai-sdk

# 或指定版本
pip install zai-sdk==0.2.3
```

##### 验证安装

```python
import zai
print(zai.__version__)
```

#### 获取 API Key

1. 访问 [智谱开放平台](https://bigmodel.cn/)
2. 注册并登录您的账户
3. 在 [API Keys](https://bigmodel.cn/usercenter/proj-mgmt/apikeys) 管理页面创建 API Key
4. 复制您的 API Key 以供使用

建议将 API Key 设置为环境变量： `export ZAI_API_KEY=YOUR_API_KEY` 替代硬编码到代码中，以提高安全性。

API 地址: [https://open.bigmodel.cn/api/paas/v4/](https://open.bigmodel.cn/api/paas/v4/)

##### 创建客户端

- 环境变量

```python
from zai import ZhipuAiClient
import os

# 从环境变量读取 API Key
client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

# 或者直接使用（如果已设置环境变量）
client = ZhipuAiClient()
```
- 直接设置

```python
from zai import ZaiClient, ZhipuAiClient

# 直接设置 API Key
client = ZhipuAiClient(api_key="YOUR_API_KEY")
```

##### 基础对话

```python
from zai import ZhipuAiClient

# Initialize client
client = ZhipuAiClient(api_key="YOUR_API_KEY")

# Create chat completion
response = client.chat.completions.create(
    model="glm-5.2",
    messages=[
        {"role": "user", "content": "你好，请介绍一下自己!"}
    ]
)
print(response.choices[0].message.content)
```

##### 流式对话

```python
# 创建流式聊天请求
from zai import ZhipuAiClient

# Initialize client
client = ZhipuAiClient(api_key="YOUR_API_KEY")

# Create chat completion
response = client.chat.completions.create(
    model='glm-5.2',
    messages=[
        {'role': 'system', 'content': '你是一个 AI 作家.'},
        {'role': 'user', 'content': '讲一个关于 AI 的故事.'},
    ],
    stream=True,
)

for chunk in response:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='')
```

##### 多轮对话

```python
from zai import ZhipuAiClient
client = ZhipuAiClient(api_key="YOUR_API_KEY")
response = client.chat.completions.create(
    model="glm-5.2",  # 请填写您要调用的模型名称
    messages=[
        {"role": "user", "content": "作为一名营销专家，请为我的产品创作一个吸引人的口号"},
        {"role": "assistant", "content": "当然，要创作一个吸引人的口号，请告诉我一些关于你产品的信息"},
        {"role": "user", "content": "智谱开放平台"},
        {"role": "assistant", "content": "点燃未来，智谱绘制无限，让创新触手可及！"},
        {"role": "user", "content": "创作一个更精准且吸引人的口号"}
    ],
)
print(response.choices[0].message.content)
```

#### 完整示例

```python
from zai import ZhipuAiClient
import os

def main():
    # 初始化客户端
    client = ZhipuAiClient(api_key=os.getenv("ZAI_API_KEY"))

    print("欢迎使用聊天机器人！输入 'quit' 退出。")

    # 对话历史
    conversation = [
        {"role": "system", "content": "你是一个友好的 AI 助手"}
    ]

    while True:
        # 获取用户输入
        user_input = input("你: ")

        if user_input.lower() == 'quit':
            break

        try:
            # 添加用户消息
            conversation.append({"role": "user", "content": user_input})

            # 创建聊天请求
            response = client.chat.completions.create(
                model="glm-5.2",
                messages=conversation,
                temperature=0.7,
                max_tokens=1000
            )

            # 获取 AI 回复
            ai_response = response.choices[0].message.content
            print(f"AI: {ai_response}")

            # 添加 AI 回复到对话历史
            conversation.append({"role": "assistant", "content": ai_response})

        except Exception as e:
            print(f"发生错误: {e}")

    print("再见！")

if __name__ == "__main__":
    main()
```

#### 错误处理

```python
from zai import ZhipuAiClient
import zai

def robust_chat(message):
    client = ZhipuAiClient(api_key="YOUR_API_KEY")

    try:
        response = client.chat.completions.create(
            model="glm-5.2",
            messages=[{"role": "user", "content": message}]
        )
        return response.choices[0].message.content

    except zai.core.APIStatusError as err:
        return f"API 状态错误: {err}"
    except zai.core.APITimeoutError as err:
        return f"请求超时: {err}"
    except Exception as err:
        return f"其他错误: {err}"

# 使用示例
result = robust_chat("你好")
print(result)
```

#### 高级配置

```python
import httpx
from zai import ZhipuAiClient

# 自定义 HTTP 客户端
httpx_client = httpx.Client(
    limits=httpx.Limits(
        max_keepalive_connections=20,
        max_connections=100
    ),
    timeout=30.0
)

# 创建带自定义配置的客户端
client = ZhipuAiClient(
    api_key="YOUR_API_KEY",
    base_url="https://open.bigmodel.cn/api/paas/v4/",
    timeout=httpx.Timeout(timeout=300.0, connect=8.0),
    max_retries=3,
    http_client=httpx_client
)
```

### 高级功能

#### 推理（thinking）

在思考模式下，GLM-5.2 可以解决复杂的推理问题，包括数学、科学和逻辑问题。

```python
from zai import ZhipuAiClient
client = ZhipuAiClient(api_key='YOUR_API_KEY')
response = client.chat.completions.create(
        model='glm-5.2',
        messages=[
            {"role": "system", "content": "you are a helpful assistant"},
            {"role": "user", "content": "what is the revolution of llm?"}
        ],
        stream=True,
        thinking={
            "type": "enabled"
        }
    )
for chunk in response:
    if chunk.choices[0].delta.reasoning_content:
        print(chunk.choices[0].delta.reasoning_content, end='')
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='')
```

#### 函数调用 (Function Calling)

函数调用允许 AI 模型调用您定义的函数来获取实时信息或执行特定操作。

##### 定义和使用函数

```python
from zai import ZhipuAiClient
import json

# 定义函数
def get_weather(location, date=None):
    """获取天气信息"""
    # 模拟天气 API 调用
    return {
        "location": location,
        "date": date or "今天",
        "weather": "晴天",
        "temperature": "25°C",
        "humidity": "60%"
    }

def get_stock_price(symbol):
    """获取股票价格"""
    # 模拟股票 API 调用
    return {
        "symbol": symbol,
        "price": 150.25,
        "change": "+2.5%"
    }

# 函数描述
tools = [
    {
        "type": "function",
        "function": {
            "name": "get_weather",
            "description": "获取指定地点的天气信息",
            "parameters": {
                "type": "object",
                "properties": {
                    "location": {
                        "type": "string",
                        "description": "地点名称"
                    },
                    "date": {
                        "type": "string",
                        "description": "日期，格式为 YYYY-MM-DD"
                    }
                },
                "required": ["location"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_stock_price",
            "description": "获取股票当前价格",
            "parameters": {
                "type": "object",
                "properties": {
                    "symbol": {
                        "type": "string",
                        "description": "股票代码"
                    }
                },
                "required": ["symbol"]
            }
        }
    }
]

# 使用函数调用
client = ZhipuAiClient(api_key="YOUR_API_KEY")

response = client.chat.completions.create(
    model='glm-5.2',
    messages=[
        {'role': 'user', 'content': '北京今天天气怎么样？'}
    ],
    tools=tools,
    tool_choice="auto"
)

# 处理函数调用
if response.choices[0].message.tool_calls:
    for tool_call in response.choices[0].message.tool_calls:
        function_name = tool_call.function.name
        function_args = json.loads(tool_call.function.arguments)

        if function_name == "get_weather":
            result = get_weather(**function_args)
            print(f"天气信息：{result}")
        elif function_name == "get_stock_price":
            result = get_stock_price(**function_args)
            print(f"股票信息：{result}")
else:
    print(response.choices[0].message.content)
```

##### 网络搜索工具

```python
from zai import ZhipuAiClient

# 初始化客户端
client = ZhipuAiClient(api_key="YOUR_API_KEY")

# 使用网络搜索工具
response = client.chat.completions.create(
    model='glm-5.2',
    messages=[
        {'role': 'system', 'content': 'You are a helpful assistant.'},
        {'role': 'user', 'content': 'What is artificial intelligence?'},
    ],
    tools=[
        {
            'type': 'web_search',
            'web_search': {
                'search_query': 'What is artificial intelligence?',
                'search_result': True,
            },
        }
    ],
    temperature=0.5,
    max_tokens=2000,
)

print(response)
```

#### 多模态处理

##### 图像理解

```python
import base64
from zai import ZhipuAiClient

def encode_image(image_path):
    """将图像编码为 base64 格式"""
    with open(image_path, 'rb') as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

client = ZhipuAiClient(api_key="YOUR_API_KEY")

# 方式1：使用图像URL
response = client.chat.completions.create(
    model="glm-5v-turbo",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "这张图片里有什么？请详细描述。"
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": "https://example.com/image.jpg"
                    }
                }
            ]
        }
    ]
)

print(response.choices[0].message.content)

# 方式2：使用base64编码的图像
base64_image = encode_image('path/to/your/image.jpg')

response = client.chat.completions.create(
    model="glm-5v-turbo",
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "text",
                    "text": "分析这张图片中的内容"
                },
                {
                    "type": "image_url",
                    "image_url": {
                        "url": f"data:image/jpeg;base64,{base64_image}"
                    }
                }
            ]
        }
    ]
)

print(response.choices[0].message.content)
```

##### 图像生成

```python
from zai import ZhipuAiClient

# Initialize client
client = ZhipuAiClient(api_key="YOUR_API_KEY")

# 图像生成
response = client.images.generations(
    model="cogview-3",
    prompt="一幅美丽的山水画，中国传统风格，水墨画",
    size="1024x1024",
    quality="standard",
)

image_url = response.data[0].url
print(f"生成的图像URL: {image_url}")

# 高质量图像生成
response = client.images.generations(
    model="cogview-3-plus",
    prompt="未来城市的概念设计，科幻风格，高清细节",
    size="1024x1024",
    quality="hd",
)

image_url = response.data[0].url
print(f"生成的图像URL: {image_url}")
```

##### 视频生成

```python
from zai import ZhipuAiClient
import time

client = ZhipuAiClient(api_key="YOUR_API_KEY")

# 提交生成任务
response = client.videos.generations(
    model="cogvideox-3",  # 使用的视频生成模型
    image_url=image_url,  # 提供的图片 URL 地址或者 Base64 编码
    prompt="让画面动起来",
    quality="speed",  # 输出模式，"quality"为质量优先，"speed"为速度优先
    with_audio=True,
    size="1920x1080",  # 视频分辨率，支持最高 4K（如: "3840x2160"）
    fps=30,  # 帧率，可选为 30 或 60
)
print(response)

# 获取生成结果
time.sleep(60)  # 等待一段时间以确保视频生成完成
result = client.videos.retrieve_videos_result(id=response.id)
print(result)
```

#### 文本嵌入

```python
# 基础文本嵌入
from zai import ZhipuAiClient
client = ZhipuAiClient(api_key="YOUR_API_KEY")

response = client.embeddings.create(
    model="embedding-3",
    input=[
        "这是第一段文本",
        "这是第二段文本",
        "这是第三段文本"
    ]
)

for i, embedding in enumerate(response.data):
    print(f"文本{i+1}的嵌入向量维度: {len(embedding.embedding)}")
    print(f"前5个维度的值: {embedding.embedding[:5]}")

# 计算文本相似度
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def calculate_similarity(texts):
    """计算文本间的相似度"""
    response = client.embeddings.create(
        model="embedding-2",
        input=texts
    )

    embeddings = [data.embedding for data in response.data]
    embeddings_array = np.array(embeddings)

    # 计算余弦相似度
    similarity_matrix = cosine_similarity(embeddings_array)

    return similarity_matrix

# 使用示例
texts = [
    "我喜欢吃苹果",
    "苹果是我最爱的水果",
    "今天天气很好"
]

similarity = calculate_similarity(texts)
print("相似度矩阵:")
print(similarity)
```

#### 流式处理

```python
class StreamProcessor:
    def __init__(self, client):
        self.client = client
        self.full_response = ""

    def stream_chat(self, messages, model="glm-5.2", callback=None):
        """流式聊天处理"""
        stream = self.client.chat.completions.create(
            model=model,
            messages=messages,
            stream=True
        )

        self.full_response = ""
        for chunk in stream:
            if chunk.choices[0].delta.content is not None:
                content = chunk.choices[0].delta.content
                self.full_response += content

                if callback:
                    callback(content, self.full_response)
                else:
                    print(content, end="", flush=True)

        print()  # 换行
        return self.full_response

# 使用示例
processor = StreamProcessor(client)

# 自定义回调函数
def on_token_received(token, full_text):
    # 可以在这里实现实时处理逻辑
    print(token, end="", flush=True)

response = processor.stream_chat(
    messages=[{"role": "user", "content": "写一个 Python 函数来计算斐波那契数列"}],
    callback=on_token_received
)
```


---

## 官方 Java SDK

来源：https://docs.bigmodel.cn/cn/guide/develop/java/introduction

Java SDK 是智谱提供的 Java 开发工具包，专为与智谱的各种人工智能模型进行交互而设计，为 Java 开发者提供便捷、高效的 AI 模型集成方案。

最新 Java SDK 版本为 `0.3.3`, 请及时更新以获取最新功能和修复。

#### 核心优势

### 企业级

专为企业应用设计，支持高并发、高可用性

### 易于集成

简洁的 API 设计，完善的文档，快速集成到现有项目

### 类型安全

完整的类型定义，编译时错误检查，减少运行时错误

### 高性能

优化的网络请求处理，支持连接池和异步调用

#### 支持的功能

- **对话聊天** ：支持单轮和多轮对话，流式和非流式响应
- **函数调用** ：让 AI 模型调用您的自定义函数
- **视觉理解** ：图像分析、视觉问答
- **图像生成** ：根据文本描述生成高质量图像
- **视频生成** ：文本到视频的创意内容生成
- **语音处理** ：语音转文字、文字转语音
- **文本嵌入** ：文本向量化，支持语义搜索
- **智能助手** ：构建专业的 AI 助手应用

### 技术规格

#### 环境要求

- **Java 版本** ：Java 1.8 或更高版本
- **构建工具** ：Maven 3.6+ 或 Gradle 6.0+
- **网络要求** ：支持 HTTPS 连接
- **API 密钥** ：需要有效的智谱 API 密钥

#### 依赖管理

SDK 采用模块化设计，您可以根据需要选择性引入功能模块：

- **核心模块** ：基础 API 调用功能
- **异步模块** ：异步和并发处理支持
- **工具模块** ：实用工具和辅助功能

### 快速开始

#### 添加依赖

- Maven

```xml
<dependency>
    <groupId>ai.z.openapi</groupId>
    <artifactId>zai-sdk</artifactId>
    <version>0.3.5</version>
</dependency>
```
- Gradle

```text
implementation 'ai.z.openapi:zai-sdk:0.3.5'
```

#### 获取 API Key

1. 访问 [智谱开放平台](https://bigmodel.cn/)
2. 注册并登录您的账户
3. 在 [API Keys](https://bigmodel.cn/usercenter/proj-mgmt/apikeys) 管理页面创建 API Key
4. 复制您的 API Key 以供使用

建议将 API Key 设置为环境变量： `export ZAI_API_KEY=YOUR_API_KEY` 替代硬编码到代码中，以提高安全性。

API 地址: [https://open.bigmodel.cn/api/paas/v4/](https://open.bigmodel.cn/api/paas/v4/)

##### 创建客户端

- 环境变量

```java
import ai.z.openapi.ZhipuAiClient;

public class QuickStart {
    public static void main(String[] args) {
        // 从环境变量读取 API Key
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(System.getenv("ZAI_API_KEY"))
            .build();

        // 或者直接使用（如果已设置环境变量）
        ZhipuAiClient client2 = ZhipuAiClient.builder().ofZHIPU().build();
    }
}
```

- 直接设置

```java
import ai.z.openapi.ZhipuAiClient;

public class QuickStart {
    public static void main(String[] args) {
        // 直接设置 API Key
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey("YOUR_API_KEY")
            .build();
    }
}
```

##### 基础对话

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.model.*;
import ai.z.openapi.core.Constants;
import java.util.Arrays;

public class BasicChat {
    public static void main(String[] args) {
        // 初始化客户端
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey("YOUR_API_KEY")
            .build();

        // 创建聊天完成请求
        ChatCompletionCreateParams request = ChatCompletionCreateParams.builder()
            .model("glm-5.2")
            .messages(Arrays.asList(
                ChatMessage.builder()
                    .role(ChatMessageRole.USER.value())
                    .content("你好，请介绍一下自己")
                    .build()
            ))
            .build();

        // 发送请求
        ChatCompletionResponse response = client.chat().createChatCompletion(request);

        // 获取回复
        if (response.isSuccess()) {
            Object reply = response.getData().getChoices().get(0).getMessage();
            System.out.println("AI 回复: " + reply);
        } else {
            System.err.println("错误: " + response.getMsg());
        }
    }
}
```

##### 流式对话

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.model.*;
import ai.z.openapi.core.Constants;
import java.util.Arrays;

public class StreamingChat {
    public static void main(String[] args) {
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey("YOUR_API_KEY")
            .build();

        // 创建流式聊天请求
        ChatCompletionCreateParams request = ChatCompletionCreateParams.builder()
            .model("glm-5.2")
            .messages(Arrays.asList(
                ChatMessage.builder()
                    .role(ChatMessageRole.USER.value())
                    .content("写一首关于春天的诗")
                    .build()
            ))
            .stream(true)
            .build();

        // 处理流式响应
        ChatCompletionResponse response = client.chat().createChatCompletion(request);

        if (response.isSuccess() && response.getFlowable() != null) {
            response.getFlowable().subscribe(
                data -> {
                    // 处理流式数据块
                    if (data.getChoices() != null && !data.getChoices().isEmpty()) {
                        Delta content = data.getChoices().get(0).getDelta();
                        System.out.print(content);
                    }
                },
                error -> System.err.println("\n 流式错误: " + error.getMessage()),
                () -> System.out.println("\n 流式完成")
            );
        }
    }
}
```

#### 完整示例

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.model.*;
import ai.z.openapi.core.Constants;
import java.util.*;

public class ChatBot {
    private final ZhipuAiClient client;
    private final List<ChatMessage> conversation;

    public ChatBot(String apiKey) {
        this.client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(apiKey)
            .build();
        this.conversation = new ArrayList<>();
        // 添加系统消息
        this.conversation.add(ChatMessage.builder()
            .role(ChatMessageRole.SYSTEM.value())
            .content("你是一个友好的 AI 助手")
            .build());
    }

    public Object chat(String userInput) {
        try {
            // 添加用户消息
            conversation.add(ChatMessage.builder()
                .role(ChatMessageRole.USER.value())
                .content(userInput)
                .build());

            // 创建请求
            ChatCompletionCreateParams request = ChatCompletionCreateParams.builder()
                .model("glm-5.2")
                .messages(conversation)
                .temperature(1.0f)
                .maxTokens(1000)
                .build();

            // 发送请求
            ChatCompletionResponse response = client.chat().createChatCompletion(request);

            if (response.isSuccess()) {
                // 获取 AI 回复
                Object aiResponse = response.getData().getChoices().get(0).getMessage().getContent();

                // 添加 AI 回复到对话历史
                conversation.add(ChatMessage.builder()
                    .role(ChatMessageRole.ASSISTANT.value())
                    .content(aiResponse)
                    .build());

                return aiResponse;
            } else {
                return "发生错误: " + response.getMsg();
            }

        } catch (Exception e) {
            return "发生错误: " + e.getMessage();
        }
    }

    public static void main(String[] args) {
        ChatBot bot = new ChatBot(System.getenv("ZAI_API_KEY"));
        Scanner scanner = new Scanner(System.in);

        System.out.println("欢迎使用智谱聊天机器人！输入 'quit' 退出。");

        while (true) {
            System.out.print("你: ");
            String input = scanner.nextLine();

            if ("quit".equalsIgnoreCase(input)) {
                break;
            }

            Object response = bot.chat(input);
            System.out.println("AI: " + response);
        }

        System.out.println("再见！");
        scanner.close();
    }
}
```

### 高级功能

#### 函数调用 (Function Calling)

函数调用允许 AI 模型调用您定义的函数来获取实时信息或执行特定操作。

##### 定义和使用函数

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.model.*;
import ai.z.openapi.core.Constants;
import java.util.*;

public class FunctionCallingExample {

    // 模拟天气 API
    public static Map<String, Object> getWeather(String location, String date) {
        Map<String, Object> weather = new HashMap<>();
        weather.put("location", location);
        weather.put("date", date != null ? date : "今天");
        weather.put("weather", "晴天");
        weather.put("temperature", "25°C");
        weather.put("humidity", "60%");
        return weather;
    }

    // 模拟股票 API
    public static Map<String, Object> getStockPrice(String symbol) {
        Map<String, Object> stock = new HashMap<>();
        stock.put("symbol", symbol);
        stock.put("price", 150.25);
        stock.put("change", "+2.5%");
        return stock;
    }

    public static void main(String[] args) {
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(System.getenv("ZAI_API_KEY"))
            .build();

        // 定义函数工具
        Map<String, ChatFunctionParameterProperty> properties = new HashMap<>();
        ChatFunctionParameterProperty locationProperty = ChatFunctionParameterProperty
                .builder().type("string").description("City name, for example: Beijing").build();
        properties.put("location", locationProperty);
        ChatFunctionParameterProperty unitProperty = ChatFunctionParameterProperty
                .builder().type("string").enums(Arrays.asList("celsius", "fahrenheit")).build();
        properties.put("unit", unitProperty);
        ChatTool weatherTool = ChatTool.builder()
                .type(ChatToolType.FUNCTION.value())
                .function(ChatFunction.builder()
                        .name("get_weather")
                        .description("获取指定地点的天气信息")
                        .parameters(ChatFunctionParameters.builder()
                                .type("object")
                                .properties(properties)
                                .required(Collections.singletonList("location"))
                                .build())
                        .build())
                .build();

        // 创建请求
        ChatCompletionCreateParams request = ChatCompletionCreateParams.builder()
                .model("glm-5.2")
                .messages(Collections.singletonList(
                        ChatMessage.builder()
                                .role(ChatMessageRole.USER.value())
                                .content("北京今天天气怎么样？")
                                .build()
                ))
                .tools(Collections.singletonList(weatherTool))
                .toolChoice("auto")
                .build();

        // 发送请求
        ChatCompletionResponse response = client.chat().createChatCompletion(request);

        if (response.isSuccess()) {
            // 处理函数调用
            ChatMessage assistantMessage = response.getData().getChoices().get(0).getMessage();
            if (assistantMessage.getToolCalls() != null && !assistantMessage.getToolCalls().isEmpty()) {
                for (ToolCalls toolCall : assistantMessage.getToolCalls()) {
                    String functionName = toolCall.getFunction().getName();

                    if ("get_weather".equals(functionName)) {
                        Map<String, Object> result = getWeather("北京", null);
                        System.out.println("天气信息: " + result);
                    }
                }
            } else {
                System.out.println(assistantMessage.getContent());
            }
        } else {
            System.err.println("错误: " + response.getMsg());
        }
    }
}
```

#### 多模态处理

##### 图像理解

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.model.*;
import ai.z.openapi.core.Constants;
import java.util.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Base64;

public class ImageUnderstanding {
    public static void main(String[] args) throws Exception {
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(System.getenv("ZAI_API_KEY"))
            .build();

        // 方式1：使用图像 URL
        ChatCompletionCreateParams request1 = ChatCompletionCreateParams.builder()
            .model(Constants.ModelChatGLM4V)
            .messages(Arrays.asList(
                ChatMessage.builder()
                    .role(ChatMessageRole.USER.value())
                    .content("这张图片里有什么？请详细描述。")
                    .build()
            ))
            .build();

        ChatCompletionResponse response1 = client.chat().createChatCompletion(request1);
        if (response1.isSuccess()) {
            System.out.println(response1.getData().getChoices().get(0).getMessage().getContent());
        }

        // 方式2：使用 base64 编码的图像
        byte[] imageBytes = Files.readAllBytes(Paths.get("path/to/your/image.jpg"));
        String base64Image = Base64.getEncoder().encodeToString(imageBytes);

        ChatCompletionCreateParams request2 = ChatCompletionCreateParams.builder()
            .model(Constants.ModelChatGLM4V)
            .messages(Arrays.asList(
                ChatMessage.builder()
                    .role(ChatMessageRole.USER.value())
                    .content("分析这张图片中的内容")
                    .build()
            ))
            .build();

        ChatCompletionResponse response2 = client.chat().createChatCompletion(request2);
        if (response2.isSuccess()) {
            System.out.println(response2.getData().getChoices().get(0).getMessage().getContent());
        }
    }
}
```

##### 图像生成

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.image.CreateImageRequest;
import ai.z.openapi.service.image.ImageResponse;
import ai.z.openapi.core.Constants;

public class ImageGeneration {
    public static void main(String[] args) {
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(System.getenv("ZAI_API_KEY"))
            .build();

        // 图像生成
        CreateImageRequest request = CreateImageRequest.builder()
                .model(Constants.ModelCogView3)
                .prompt("一幅美丽的山水画，中国传统风格，水墨画")
                .size("1024x1024")
                .build();

        ImageResponse response = client.images().createImage(request);

        if (response.isSuccess()) {
            String imageUrl = response.getData().getData().get(0).getUrl();
            System.out.println("生成的图像 URL: " + imageUrl);
        }
    }
}
```

#### 文本嵌入

```java
import ai.z.openapi.ZhipuAiClient;
import ai.z.openapi.service.embedding.Embedding;
import ai.z.openapi.service.embedding.EmbeddingCreateParams;
import ai.z.openapi.service.embedding.EmbeddingResponse;
import ai.z.openapi.core.Constants;
import java.util.Arrays;

public class TextEmbedding {
    public static void main(String[] args) {
        ZhipuAiClient client = ZhipuAiClient.builder().ofZHIPU()
            .apiKey(System.getenv("ZAI_API_KEY"))
            .build();

        // 基础文本嵌入
        EmbeddingCreateParams request = EmbeddingCreateParams.builder()
                .model(Constants.ModelEmbedding2)
                .input(Arrays.asList(
                        "这是第一段文本",
                        "这是第二段文本",
                        "这是第三段文本"
                ))
                .build();

        EmbeddingResponse response = client.embeddings().createEmbeddings(request);

        if (response.isSuccess()) {
            for (int i = 0; i < response.getData().getData().size(); i++) {
                Embedding embedding = response.getData().getData().get(i);
                System.out.println("文本" + (i + 1) + "的嵌入向量维度: " + embedding.getEmbedding().size());
                System.out.println("前 5 个维度的值: " + embedding.getEmbedding().subList(0, 5));
            }
        }
    }
}
```
