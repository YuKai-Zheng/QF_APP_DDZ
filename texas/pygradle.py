# -*- coding:utf-8 -*- 
import sys,os
if len(sys.argv) <3:
	print("Parameter missing !\n\
	first is task \n\
	second is mode (debug or release)\n\
	")
	exit()

task = sys.argv[1]
mode = sys.argv[2]

if mode !="-d" and mode!="-r":
	print("Mode has wrong!")
	print("release -r ")
	print("debug -d")
	exit()



mode = mode=="-r" and "release" or "debug"
task_arr = {'normal':'com.azhuanle.qipai',\
'qule':'com.azqule.qipai',\
'tiantian':'com.azqule.qipaic',\
'tongliao':'com.azqule.qipaif',\
'xilingole':'com.azhuanle.qipaie',\
'kuaile':'com.azqule.qipaid'\
}


def pack(task,mode):
	path = sys.path[0]
	##从模板中读取替换为对应的包名
	file_path = ("%s\sample\WXEntryActivity.java") % (path)
	all_the_text = open(file_path).read( )
	all_the_text= all_the_text.replace('{packagename}',task_arr[task])

	file_code_path = ("%s\\frameworks\\runtime-src\proj.android\src\main\java\com\qufan\\texas\wxapi\WXEntryActivity.java") % (path)
	file = open(file_code_path,'w')
	file.write(all_the_text)
	file.close()
	command = ("gradle assemble%s%s") % (task,mode)
	print(command)
	os.system(command)


if task =="-a":
	for k,v in task_arr.items():
		pack(k,mode)
else:
	if not task_arr.has_key(task):
		print("the task is not exsit! ")
		exit()

	pack(task,mode)







	

