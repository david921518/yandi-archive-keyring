#!/bin/bash
# 输入: LDIF文件
# 输出: index 和 index.sig

TMPDIR=$(mktemp -d)
OUTDIR="team-members"

# 解析LDAP数据
ldapsearch -LLL -x -b "ou=users,dc=debian,dc=org" \
  "(objectClass=debianDeveloper)" \
  uid gn sn debian-keyring-fingerprint \
  > $TMPDIR/dacs.ldif

# 生成索引头
echo "# Debian Team Members Keyring" > $OUTDIR/index
echo "# Generated: $(date -u +'%Y-%m-%d %H:%M:%S UTC')" >> $OUTDIR/index
echo "#" >> $OUTDIR/index
printf "%-40s %-40s %s\n" "Filename" "Fingerprint" "UID" >> $OUTDIR/index
echo "================================================================================" >> $OUTDIR/index

# 处理每个成员
while IFS= read -r line; do
  if [[ $line =~ ^uid:\ (.*) ]]; then
      uid=${BASH_REMATCH[1]}
  elif [[ $line =~ ^gn:\ (.*) ]]; then
      gn=${BASH_REMATCH[1]}
  elif [[ $line =~ ^sn:\ (.*) ]]; then
      sn=${BASH_REMATCH[1]}
  elif [[ $line =~ ^debian-keyring-fingerprint:\ (.*) ]]; then
      fpr=${BASH_REMATCH[1]}
      
      # 生成文件名
      filename="${uid}_${fpr: -16}.asc"
      
      # 添加到索引
      printf "%-40s %-40s %s %s\n" \
        "$filename" "$fpr" "$gn" "$sn" >> $OUTDIR/index
      
      # 记录生成任务
      echo "$fpr:$filename:$gn $sn" >> $TMPDIR/keylist.txt
  fi
done < $TMPDIR/dacs.ldif

# 签名索引
gpg --default-key "Debian Keyring Maintainer" \
    --clearsign $OUTDIR/index
mv $OUTDIR/index.asc $OUTDIR/index.sig

rm -rf $TMPDIR
