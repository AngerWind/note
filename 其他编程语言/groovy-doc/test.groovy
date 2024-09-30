import groovy.transform.TupleConstructor

/**
 * @author Tiger.Shen
 * @date 2024/9/7
 * @description
 * @version 1.0
 */


def binding = new Binding()
def shell = new GroovyShell(binding)
binding.setVariable('x', 1)
binding.setVariable('y', 3)
shell.evaluate """
	def a = 2 // 定义一个局部变量
	b = 5 // 定义一个变量b, 然后设置到Binding中
	y = 4 // 将Binding中的y设置为4
	z = a*y*x // 定义一个变量z, 然后设置到Binding中
"""
println(binding.getVariable('z')) // 从Binding中获取变量z的值, 8


