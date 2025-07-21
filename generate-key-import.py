#!/usr/bin/env python3
# generate-key-import.py
import datetime
import textwrap

comment = "add bookworm stable key"
action = "import"
key_data = open("bookworm-stable.asc").read()

# 生成 RFC 2822 格式时间戳
now = datetime.datetime.utcnow()
date_str = now.strftime("%a, %d %b %Y %H:%M:%S +0000")

# 构建文件内容
output = f"Comment: {comment}\n"
output += f"Date: {date_str}\n"
output += f"Action: {action}\n"
output += "Data: \n"
output += textwrap.indent(key_data, "  ", lambda line: True)

with open("bookworm-stable.keyimport", "w") as f:
    f.write(output)
