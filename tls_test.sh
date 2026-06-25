#!/bin/bash

domains=(
www.microsoft.com
login.live.com
www.apple.com
www.icloud.com
www.cloudflare.com
www.google.com
aws.amazon.com
github.com
www.youtube.com
www.netflix.com
playstation.com
cdn.jsdelivr.net
cdnjs.cloudflare.com
www.fastly.com
duckduckgo.com
is1-ssl.mzstatic.com
bing.com
www.bing.com
c.6sc.co
services.digitaleast.mobi
)

echo "===== TLS握手测试开始 ====="
echo ""

results=()

for d in "${domains[@]}"; do
  echo "测试: $d"

  ok=0
  sum=0
  min=999999
  max=0

  for i in {1..5}; do
    t=$(curl -o /dev/null -s --connect-timeout 2 \
      -w "%{time_appconnect}" https://$d)

    if [ -n "$t" ]; then
      val=$(awk "BEGIN{print $t*1000}")

      ok=$((ok+1))
      sum=$(awk "BEGIN{print $sum+$val}")

      min=$(awk "BEGIN{if($val<$min) print $val; else print $min}")
      max=$(awk "BEGIN{if($val>$max) print $val; else print $max}")
    fi
  done

  if [ $ok -gt 0 ]; then
    avg=$(awk "BEGIN{print $sum/$ok}")
    echo "  成功率: $ok/5"
    echo "  平均: ${avg} ms"
    echo "  最小: ${min} ms"
    echo "  最大: ${max} ms"

    results+=("$avg|$d")
  else
    echo "  失败: 全部超时"
    results+=("999999|$d")
  fi

  echo ""
done

echo "=============================="
echo "        TOP 3 推荐（检测结果）"
echo "=============================="

IFS=$'\n'
sorted=($(sort -t"|" -k1 -n <<< "${results[*]}"))

for i in 0 1 2; do
  item="${sorted[$i]}"
  avg=$(echo $item | cut -d"|" -f1)
  dom=$(echo $item | cut -d"|" -f2)

  echo "TOP $((i+1))：$dom"
  echo "   平均TLS握手: ${avg} ms"
done
