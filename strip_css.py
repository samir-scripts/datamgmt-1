import os
import re

def strip_style_tags(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.jsp') or file.endswith('.html'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Regex to remove <style>...</style> blocks
                new_content = re.sub(r'<style>.*?</style>', '', content, flags=re.DOTALL)
                
                if new_content != content:
                    # Also let's wrap everything in a <body bgcolor="lightgray"> to make it look slightly "worse"
                    # Or just leave it as default white. Default white with times new roman is peak 90s.
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Stripped styles from {filepath}")

strip_style_tags('/Users/samirkatakamsetty/Desktop/Home/datamgmt-1/WebContent')
