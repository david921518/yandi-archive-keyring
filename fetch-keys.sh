#!/bin/bash
# 输入: keylist.txt (fpr:filename:name)
# 输出: team-members/*.asc

KEYLIST="$1"
OUTDIR="team-members"

while IFS=: read -r fpr filename name; do
  # 从密钥服务器获取
  gpg --keyserver hkps://keys.openpgp.org \
      --recv-keys "$fpr"
  
  # 导出ASCII格式
  gpg --armor --export "$fpr" > "$OUTDIR/$filename"
  
  # 验证指纹匹配
  exported_fpr=$(gpg --with-fingerprint --with-colons "$OUTDIR/$filename" | 
                 awk -F: '$1 == "fpr" {print $10}')
  
  if [ "$exported_fpr" != "$fpr" ]; then
      echo "ERROR: Fingerprint mismatch for $name"
      exit 1
  fi
done < "$KEYLIST"
