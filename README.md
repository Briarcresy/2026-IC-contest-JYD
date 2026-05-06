- 语言：SystemVerilog

- git协作流程：
  - main分支存放可随时提交的、没有bug的CPU正式版本
  - develop分支作为CPU工作分支，平时在develop上修改，等成熟了之后合并进main分支
  - 每个人先从develop分支拉出自己的分支，做完一个阶段性任务之后merge进develop分支，避免两个人同时在develop分支上面打架

- 代码尽量参数化、模块化

- VScode安装HDL格式化插件：SystemVerilog and Verilog Formatter

	.json配置：
```JSON
{
	"[verilog]": {
		"editor.defaultformatter": "bmpenuelas.systemverilog-formatter-vscode"
	},
	"[systemverilog]": {
		"editor.defaultFormatter": "bmpenuelas.systemverilog-formatter-vscode"
	},
	"editor.tabSize": 4,
	"editor.insertSpaces": false,
	"editor.detectIndentation": false,
	"systemverilogFormatter.commandLineArguments": "--indentation_spaces=4",
}
```

- 码风规范：暂时先随便写，等样本多了再统一