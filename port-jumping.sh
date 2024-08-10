#!/bin/bash

# 脚本名称: configure-iptables.sh

# 检查是否以 root 用户身份运行
if [ "$(id -u)" -ne "0" ]; then
    echo "请以 root 用户身份运行此脚本"
    exit 1
fi

# 提示用户输入端口范围和目标端口
read -p "请输入 UDP 端口范围（格式：20000:50000）： " PORT_RANGE
read -p "请输入 UDP 目标端口： " TARGET_PORT

# 确保用户输入了端口范围和目标端口
if [ -z "$PORT_RANGE" ] || [ -z "$TARGET_PORT" ]; then
    echo "端口范围和目标端口不能为空"
    exit 1
fi

# 清除现有的 iptables 规则
iptables -F
iptables -X

# 设置默认策略
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p udp --dport $TARGET_PORT -j ACCEPT
iptables -A INPUT -p udp --dport $PORT_RANGE -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT

# 保存规则
iptables-save > /etc/iptables/rules.v4

# 设置 NAT 转发规则
iptables -t nat -A PREROUTING -p udp --dport $PORT_RANGE -j DNAT --to-destination :$TARGET_PORT

# 查看规则
iptables -L
iptables -t nat -nL --line-numbers
