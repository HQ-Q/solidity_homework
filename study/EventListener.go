package main

import (
	"context"
	"fmt"
	"log"
	"math/big"

	"strings"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
)

// 配置信息
const (
	// 可以替换为你自己的Infura API密钥或其他节点URL
	sepoliaNodeURL = "wss://sepolia.infura.io/ws/v3/1cf6fcfaeb794afaa777055f861ac5ae"

	// 示例合约地址 - 替换为你要监听的合约地址
	contractAddress = "0xede064F7bDF84C96838890C635e66Bc40731FE24"

	// 示例ABI - 你需要替换成你实际合约的ABI
	contractABI = `[{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]`
)

func main() {
	// 连接到Sepolia测试网
	client, err := ethclient.Dial(sepoliaNodeURL)
	if err != nil {
		log.Fatalf("无法连接到以太坊节点: %v", err)
	}
	fmt.Println("成功连接到Sepolia测试网")

	// 转换合约地址
	addr := common.HexToAddress(contractAddress)

	// 获取最新区块号
	latestBlock, err := client.BlockNumber(context.Background())
	if err != nil {
		log.Fatalf("获取最新区块号失败: %v", err)
	}
	fmt.Printf("当前最新区块: %d\n", latestBlock)

	// 定义事件过滤器查询
	query := ethereum.FilterQuery{
		Addresses: []common.Address{addr},
		// 从最新区块开始监听，如果想监听历史区块，可以设置FromBlock
		FromBlock: big.NewInt(int64(latestBlock)),
	}

	// 创建事件通道
	logs := make(chan types.Log)

	// 启动过滤器
	sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatalf("创建日志订阅失败: %v", err)
	}
	defer sub.Unsubscribe()

	// 解析ABI
	parsedABI, err := abi.JSON(strings.NewReader(contractABI))
	if err != nil {
		log.Fatalf("解析ABI失败: %v", err)
	}

	fmt.Printf("开始监听合约 %s 的事件...\n", contractAddress)
	fmt.Println("按Ctrl+C停止监听")

	// 监听事件
	for {
		select {
		case err := <-sub.Err():
			log.Printf("订阅错误: %v", err)
			return
		case vLog := <-logs:
			fmt.Printf("\n收到新事件: %+v\n", vLog)
			fmt.Printf("区块号: %d\n", vLog.BlockNumber)
			fmt.Printf("交易哈希: %s\n", vLog.TxHash.Hex())
			fmt.Printf("事件索引: %d\n", vLog.Index)
			fmt.Printf("事件数据(原始): %s\n", common.Bytes2Hex(vLog.Data))

			// 解码事件数据
			eventName, eventData, err := parseEvent(parsedABI, vLog)
			if err != nil {
				fmt.Printf("解码事件失败: %v\n", err)
			} else {
				fmt.Printf("事件名称: %s\n", eventName)
				fmt.Printf("解码后的事件数据: %+v\n", eventData)
			}
			// 如果需要解析事件参数，可以在这里添加解析逻辑
			// 解析需要知道事件的ABI和具体结构
		}
	}
}

// parseEvent 根据ABI解析事件
func parseEvent(abi abi.ABI, log types.Log) (string, map[string]interface{}, error) {
	// 根据topic查找事件
	for _, event := range abi.Events {
		if log.Topics[0].Hex() == event.ID.Hex() {
			data := make(map[string]interface{})
			err := abi.UnpackIntoMap(data, event.Name, log.Data)
			if err != nil {
				return event.Name, nil, err
			}

			// 添加索引参数（topics除了第一个以外）
			for i, input := range event.Inputs {
				if input.Indexed {
					if len(log.Topics) > i+1 {
						data[input.Name] = log.Topics[i+1].Hex()
					}
				}
			}

			return event.Name, data, nil
		}
	}
	return "", nil, fmt.Errorf("未找到匹配的事件")
}
