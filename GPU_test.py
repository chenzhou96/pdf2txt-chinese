import easyocr
import torch
import os

# 检查是否支持 GPU
gpu_available = torch.cuda.is_available()
print(f"GPU Available: {gpu_available}")

# 创建一个 Reader，启用简体中文（语言代码为 ch_sim）
reader = easyocr.Reader(['ch_sim', 'en'], gpu=gpu_available)

# 测试文字识别
image_path = r"test.png"

# 检查文件是否存在
if not os.path.exists(image_path):
    print(f"错误：文件 '{image_path}' 不存在！")
    exit()

try:
    result = reader.readtext(image_path)
    print("识别结果:")
    for detection in result:
        text = detection[1]
        print(text)
except Exception as e:
    print(f"识别失败：{str(e)}")