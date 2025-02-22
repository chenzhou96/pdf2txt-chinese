import easyocr
import pdf2image
from PyPDF2 import PdfReader
from tqdm import tqdm
import os
import numpy as np

os.environ['PYTORCH_CUDA_ALLOC_CONF'] = 'expandable_segments:True'

def get_num_pages(pdf_path):
    reader = PdfReader(pdf_path)
    return len(reader.pages)

def process_single_page(pdf_path, page_number, output_file):
    reader = easyocr.Reader(['en', 'ch_sim'], gpu=True)
    images = pdf2image.convert_from_path(pdf_path, dpi=250, first_page=page_number, last_page=page_number, poppler_path=r'D:\Program\poppler-24.08.0\Library\bin')
    
    if images:
        np_image = np.array(images[0])
        result = reader.readtext(np_image)
        text = ' '.join([res[1] for res in result])
        print(f"\nPage {page_number} Text:\n{text}")
        
        # 将每一页的内容追加到文件中
        with open(output_file, 'a', encoding='utf-8') as file:
            file.write(text + "\n")

    # 关闭reader以释放资源
    del reader

def extract_text_from_pdf(pdf_path, num_pages, output_file):
    for page_number in tqdm(range(1, num_pages + 1), desc="Processing Pages"):
        process_single_page(pdf_path, page_number, output_file)

pdf_path = r"C:\Users\zhouc\Desktop\JFL.pdf"
output_file = 'extracted_text.txt'
num_pages = get_num_pages(pdf_path)
extract_text_from_pdf(pdf_path, num_pages, output_file)

print("Text extraction and saving complete.")