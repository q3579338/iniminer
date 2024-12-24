#!/bin/bash

# 配置
SESSION_NAME="iniminer"  # screen 会话名称
COMMAND="./iniminer-linux-x64 --pool stratum+tcp://0x0F62ecEF9d6d74A038e6e8489932c581307e5609.Worker030@pool-core-testnet.inichain.com:32672"
MODE=$1 # 接受第一个参数作为模式：--full, --half, --local
CHECK_INTERVAL=60 # 检测间隔时间（秒）

# 定义 CPU 模式
FULL_CORES=$(seq 0 2 38 | awk '{printf "--cpu-devices %s ", $1}')
HALF_CORES=$(seq 0 4 38 | awk '{printf "--cpu-devices %s ", $1}')
LOCAL_CORES="--cpu-devices 0 --cpu-devices 2 --cpu-devices 4 --cpu-devices 6 --cpu-devices 8 --cpu-devices 10 --cpu-devices 12 --cpu-devices 14 --cpu-devices 16 --cpu-devices 18 --cpu-devices 20 --cpu-devices 22 --cpu-devices 24 --cpu-devices 26 --cpu-devices 28 --cpu-devices 30 --cpu-devices 32 --cpu-devices 34 --cpu-devices 36 --cpu-devices 38"

# 根据模式设置命令
if [[ $MODE == "--full" ]]; then
    FINAL_COMMAND="$COMMAND $FULL_CORES"
elif [[ $MODE == "--half" ]]; then
    FINAL_COMMAND="$COMMAND $HALF_CORES"
elif [[ $MODE == "--local" ]]; then
    FINAL_COMMAND="$COMMAND $LOCAL_CORES"
else
    echo "使用方法: $0 [--full|--half|--local]"
    exit 1
fi

# 启动挖矿程序
start_miner() {
    echo "启动挖矿程序模式: $MODE"
    screen -dmS "$SESSION_NAME" bash -c "$FINAL_COMMAND"
}

# 检测是否运行中
check_miner() {
    screen -ls | grep -q "$SESSION_NAME"
    if [[ $? -ne 0 ]]; then
        echo "挖矿程序未运行，重新启动..."
        start_miner
    else
        echo "挖矿程序正在运行..."
    fi
}

# 主循环
while true; do
    check_miner
    sleep $CHECK_INTERVAL
done
