// 不管当前这个文件处在哪个模块中
// 只要是声明了main函数, 那么他的package就必须是main
// 否则main函数只会被当做是普通的函数
package main

import "fmt"

func main() {
	fmt.Println("hello world")
}
