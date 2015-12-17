" Vim filetype plugin file
" Language:	Verilog HDL
" Maintainer:	Chih-Tsun Huang <cthuang@larc.ee.nthu.edu.tw>
" Last Change:	Mon Sep  5 11:05:54 CST 2005 and 2006 April 30
" URL:		http://larc.ee.nthu.edu.tw/~cthuang/vim/ftplugin/verilog.vim
" Last Change Time:    2015/8/15 11:30:00
" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
  finish
endif

" Don't load another plugin for this buffer
let b:did_ftplugin = 1

" Undo the plugin effect
let b:undo_ftplugin = "setlocal fo< com< tw<"
    \ . "| unlet! b:browsefilter b:match_ignorecase b:match_words"

" Set 'formatoptions' to break comment lines but not other lines,
" and insert the comment leader when hitting <CR> or using "o".
setlocal fo-=t fo+=croqlm1

" Set 'comments' to format dashed lists in comments.
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://

" Format comments to be up to 78 characters long
if &textwidth == 0 
  setlocal tw=78
endif

set cpo-=C

" Win32 can filter files in the browse dialog
if has("gui_win32") && !exists("b:browsefilter")
  let b:browsefilter = "Verilog Source Files (*.v)\t*.v\n" .
	\ "All Files (*.*)\t*.*\n"
endif

" Let the matchit plugin know what items can be matched.
if exists("loaded_matchit")
  let b:match_ignorecase=0
  let b:match_words=
    \ '\<begin\>:\<end\>,' .
    \ '\<case\>\|\<casex\>\|\<casez\>:\<endcase\>,' .
    \ '\<module\>:\<endmodule\>,' .
    \ '\<if\>:\<else\>,' .
    \ '\<function\>:\<endfunction\>,' .
    \ '`ifdef\>:`else\>:`endif\>,' .
    \ '\<task\>:\<endtask\>,' .
    \ '\<specify\>:\<endspecify\>'
endif


nnoremap <leader>c :s/^/\/\/ /<CR>:nohl<CR>
nnoremap <leader>n :s/^\/\/ //<CR>:nohl<CR>
vnoremap <leader>c :s/^/\/\/ /<CR>:nohl<CR>
vnoremap <leader>n :s/^\/\/ //<CR>:nohl<CR>
nnoremap <leader><leader>c i/<Esc>50a*<Esc>a/<Esc>26hi<Tab><Tab><Tab><Esc>4hi

nmap <C-F1> :call SetHeader()<CR>
" autocmd BufWinLeave *.v :call ChangeTime()
" autocmd VimEnter *.v :call ChangeTime()

nnoremap <S-C-F1> :call ChangeTime()<CR>

set foldmarker={{{/{,}}}/}


"""""""""""""""""""""""""      Auto inst{{{     """""""""""""""""""""""""""
function! Auto_inst()"{{{/{
""" 自动例化
"""""""""""""""""""记录当前文件名""""""""""""""""""""""""""
    let current_file = bufname("%") 
    echo "current_file:".current_file

"""""""""""""""""""记录当前行号"""""""""""""""""""""""
    let current_line = line(".")
    echo "line_current:".current_line

"""""""""""""""""""get current line
    let str = getline(current_line)
    echo "line_str:".str

""""""""""""""""""""get current buffer id"""""""""""""""""
    let current_nr = bufnr("%") 

"""""""""""""""""""""parse current line get the target module name
    let module_name = matchstr(str, '\w\+')
    let inst_name = substitute(str, '\s*\w\+\s*', "", "")
    echo "module_name:".module_name

"""""""""""""""""""""construct target module's file name
    let module_file = module_name.".v"
    echo "module_file:". module_file

    echo " "
    
""""""""""""""""""""""   check the file exist or not """"""""""""""""""""""
    let a=filereadable(module_file)  
"     let b=filereadalbe("../".module_file)
    echo "filereadble: ".a
    if a == 0 
        echo module_file." do not exist"
        pwd
        set path=,..
        execute "find " module_file
        cho a
"         return
    else
        execute "find " module_file
        echo "open ".module_file
        set path=,.
"         execute "view " module_file
    endif

"""""""""""""""""""""""""   open module         """"""""""""""""""""""""""""   

""""""""""""""""""""""""""  record the port defination start line""""""""""""""
    gg
    /\<module\> 
    let l1=line(".")

""""""""""""""""""""""""""  record port defination end line """"""""""""""""""
    /^\s*);
    let l2=line(".")
    echo "start line: ".l1
    echo "end line: ".l2

"""""""""""""""""""""""""  find  parameter and port """""""""""""""""""""""""""
    let parameter_list = []
    let port_list =[]
    let l1 += 1
    while l1 <= l2
        let str = getline(l1)

"""""""""""""""""""""""""  delete nosie characters   """""""""""""""""""""""""""
        let str=substitute(str, '\s*\/\/.*\s*', "", "") 
        let str=substitute(str, '\s*', "", "") 
        let str=substitute(str, '(', "", "") 
        let str=substitute(str, ')', "", "") 
        let str=substitute(str, ',', "", "") 
        let str=substitute(str, ';', "", "") 
        let str=substitute(str, '#', "", "") 
        let l1 = l1+1

"""""""""""""""""""""""""  check belong to parameter block or not       """""""""""""""""""""""""""
        let match_flag = match(str, "parameter")
        if match_flag != -1
            let str=substitute(str, '\s*parameter\s*', "", "") 
            let str=substitute(str, '\s*=.*\s*', "", "") 

"""""""""""""""""""""""""      add to parameter list     """""""""""""""""""""""""""
            if str!= ""
                let parameter_list += [str]
            endif
        else
            let str=substitute(str, '\s*input\s*', "", "") 
            let str=substitute(str, '\s*output\s*', "", "") 
            let str=substitute(str, '\s*wire\s*', "", "") 
            let str=substitute(str, '\s*reg\s*', "", "") 
            let str=substitute(str, '\s*\[.*\]\s*', "", "") 
            if str != ""
                let port_list += [str]
            endif
        endif
    endwhile

""""""""""""""""""""""""""""open the source file """"""""""""""""""""""
     execute "buffer " current_file

"""""""""""""""""""""""""""delete current line""""""""""""""""""""""""
     delete

""""""""""""""""""""""""""""append line"""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""append parameter"""""""""""""""""""""""""""""""
    let append_line = current_line - 1
    if parameter_list != []
        call append(append_line, module_name)
        let append_line += 1


        call append(append_line, "#(")
        let append_line += 1

        let start_line = append_line + 1

        let index = 0
        while index < len(parameter_list)
            let atom = parameter_list[index]
            if index < len(parameter_list) - 1
                call append(append_line, "  .".atom."(".atom."),")
                let append_line += 1
            else
                call append(append_line, "  .".atom."(".atom.")")
                let append_line += 1
            endif
            let index = index + 1
        endwhile

        call append(append_line, ")")
        let append_line += 1

        let end_line = append_line - 1

        echo start_line
        echo end_line
        execute start_line.",".end_line."Align("
        execute start_line.",".end_line."Align)"

        call append(append_line, inst_name."(")
        let append_line += 1
    else
        call append(append_line, module_name." ".inst_name."(")
        let append_line += 1
    endif
""""""""""""""""""""""""""""append ports"""""""""""""""""""""""""""""""
    let start_line = append_line + 1
    let index = 0
    while index < len(port_list)
        let atom = port_list[index]
        if index < len(port_list) - 1
            call append(append_line, "  .".atom."(".atom."),")
            let append_line += 1
        else
            call append(append_line, "  .".atom."(".atom.")")
            let append_line += 1
        endif
        let index = index + 1
    endwhile

    call append(append_line, ");")
    let end_line = append_line

    echo start_line
    echo end_line
"""""""""""""""""""""""""  execute the string as an Ex command          """""""""""""""""""""""""""
"""""""""""""""""""""""""  Align the bracket    """""""""""""""""""""""""""
"     execute start_line.",".end_line."Align)"
    execute start_line.",".end_line."Align("
    execute start_line.",".end_line."Align)"

    echo "port list: " port_list
    echo "parameter list: " parameter_list
    return 1
endfunction
"""""""""""""""""""""""""      }}}     """""""""""""""""""""""""""
"}}}/}
"

func! SetHeader() "如果文件类型为.sh文件 
    let dir = getcwd()
    echo dir
    let dirs = split(dir, '\')
    echo dirs
    let module_name = dirs[-1]
    if module_name == "dut"
      let project_name = dirs[-3]
      let module_name  = project_name
    else
      let project_name = dirs[-4]
    endif
    call append(0, "`timescale 1ns / 1ps")         
    call append(1, "////////////////////////////////////////////////////////////////////////////////////////////////////")         
    call append(2, "// Company:             Hikvision Co.,LTC")
    call append(3, "// Engineer:            ChenKai")
    call append(4, "// Create Time:         ".strftime("%c"))
    call append(5, "// Last Change Time:    ".strftime("%c"))
    call append(6, "// Design Name:         ".expand("%"))
    call append(7, "// Module Name:         ".module_name)
    call append(8, "// Project Name:        ".project_name)
    call append(9, "// Target Devices:  ")
    call append(10, "// Tool versions:  ")
    call append(11, "// Description:    ")
    call append(12, "// Dependencies: ")
    call append(13, "// Revision: ")
    call append(14, "// Revision 0.01 - File Created")
    call append(15, "// Additional Comments: ")
    call append(16, "////////////////////////////////////////////////////////////////////////////////////////////////////")         
    let file_name = expand("%")
    echo file_name
    let design_names = split(file_name, '\.')
    let design_name = design_names[0]
    echo design_names
    call append(17, "module ".design_name)
    call append(18, "endmodule ")
endfunc 

function! Test_py()
python << EOF
import vim
import os
import sys
import re
path = vim.eval("getcwd()")
print path
print "hello"
EOF
endfunc

function! Parse_header()
python << EOF
import vim
import os
import sys
import re
print "Parse_header"
# 获取当前buffername
buf = vim.current.buffer
#print("current buf name:"+buf)
# 获取当前行以获得例化模块名
line = vim.current.line
print "current line:"+line 
list_name = line.split(" ")
while "" in list_name:
    list_name.remove("")
mod_name  = list_name[0]
inst_name = list_name[1]
print "module name:"+mod_name 
print "instance name:"+inst_name 
# 获取例化模块, 使用os.walk获取dut下所有文件,获取ip下所有funcsim.v
path=vim.eval("getcwd()")
print path 
root = path.find("rtl")
print root 
print path[0:root+3] 
dut_root = path[0:root+3]+"/dut"
ip_root  = path[0:root+3]+"/ip"
find_file = False

# 首先在dut下搜索
wid = os.walk(dut_root)
module_name = list_name[0] + ".v"
for rootDir, pathList, fileList in wid:  
    for file in fileList:  
      #print('file ' + os.path.join(rootDir, file) )
        if(file == module_name):
            print file 
            find_file = True
            file_path = os.path.join(rootDir, file)
            #        print('file ' + os.path.join(rootDir, file) )
    if(find_file == True):
        print 'find file under dut, path:'+file_path  
        break
# 如果没有找到,在ip下搜索
if(find_file == False):
    module_name = list_name[0] + "_funcsim.v"
    wid = os.walk(dut_root)
    for rootDir, pathList, fileList in wid:  
      for file in fileList:  
          if(file == module_name):
              find_file = True
              file_path = os.path.join(rootDir, file)
              # print('file ' + os.path.join(rootDir, file) )
      if(find_file == True):
          break
# 如果都没有找到,打印信息,结束
if(find_file == False):
    print "erro, do not find file under dut and ip" 
# 打开module文件,然后读取文件,逐行扫描,记录端口名,端口位宽,以及端口注释
if(find_file == True):
    module_file = open(file_path, "r")
    line = module_file.readline()
    parameter = []
    port = []
    parameter_comment = []
    port_comment = []
    after_module = False
    module_pattern = re.compile("^\s*module ")
    comment_pattern = re.compile(".*(//.*)")
    parameter_start_pattern = re.compile("^\s*#\s*\(")
    parameter_end_pattern = re.compile("^.*\)")
    in_parameter = 0
    port_start_pattern = re.compile("^.*\(")
    port_end_pattern = re.compile("^.*\)\s*;")
    in_port = 0
    while line:
        if(after_module):
        # 解析当前行
            # 另一种解决方案:1. 获取注释;2. 去掉无效字符; 3. 判断parameter或port; 4. 添加对应的list
            parameter_start = parameter_start_pattern.match(line)
            parameter_end   = parameter_end_pattern.match(line)
            ports_start     = port_start_pattern.match(line)
            ports_end       = port_end_pattern.match(line)
            if parameter_start:
                print "find parameter start:" + line 
                # 进入检测parameter
                in_parameter = 1
            else:
                if ports_start:
                    print "fine port start:" + line 
                    in_port = 1
            if parameter_end:
                print "find parameter end:" + line 
                in_parameter = 0
            if ports_end:
                print "find port end:" + line 
                in_port = 0
    
            has_comment = comment_pattern.match(line)
            if has_comment:
                current_comment = has_comment.group(1)
            line=re.sub("\s*//.*", "", line)
            line=re.sub(".*#", "", line)
            line=re.sub(".*\(", "", line)
            line=re.sub("\).*", "", line)
            line=re.sub("parameter", "", line)
            line=re.sub(",", "", line)
            line=re.sub("=.*", "", line)
            line=re.sub("module", "", line)
            line=re.sub(" ", "", line)
            line=re.sub("\n", "", line)
            line=re.sub("\r", "", line)
    
            if line!="":
                if(in_parameter == 1):
                    parameter.append(line)
                    if(has_comment):
                        parameter_comment.append(current_comment)
                    else:
                        parameter_comment.append(" ")
                elif(in_port == 1):
                    port.append(line)
                    if(has_comment):
                        port_comment.append(current_comment)
                    else:
                        port_comment.append(" ")
        line = module_file.readline()
        # 如果找到");"即退出
        index = line.find(");")
        if(index != -1):
            break
        index = module_pattern.match(line)
        if index:
            after_module = True
    module_file.close()  
    # 向当前文本中添加内容
    print "port" 
    print port 
    print "port_comment" 
    print port_comment 
    print "parameter" 
    print parameter 
    print "parameter_comment" 
    print parameter_comment 
    
    #vim.current.buffer.append("test line")
    pos = vim.current.window.cursor
    print "current line num" + str(pos[0]) 
    print pos[0] 
    # 删除一行, 注意下标从0开始
    del vim.current.buffer[pos[0]-1]
    start_num = pos[0] - 1
    cur_num   = start_num
    # 增加一行
    if(len(parameter) != 0):
        #添加模块名
        vim.current.buffer.append(mod_name, cur_num)
        cur_num = cur_num + 1
        vim.current.buffer.append("#(", cur_num)
        cur_num = cur_num + 1
        #添加parameter例化
        for p in range(len(parameter)):
            if(p < len(parameter) - 1):
                vim.current.buffer.append("  ."+parameter[p]+" ( " + parameter[p] + " )," + parameter_comment[p], cur_num)
            else:
                vim.current.buffer.append("  ."+parameter[p]+" ( " + parameter[p] + " )" + parameter_comment[p], cur_num)
            cur_num = cur_num + 1
        # parameter 对齐
        #添加例化名
        print str(start_num+3) + " " + str(cur_num) 
        if( start_num + 3 < cur_num):
            vim.command(str(start_num+3) + ", " + str(cur_num)  + " Align ( ) //")
        vim.current.buffer.append(") "+inst_name+" ( " , cur_num)
        cur_num = cur_num + 1
        port_start_num = cur_num
        #添加port例化
        for p in range(len(port)):
            if(p < len(port) - 1):
                vim.current.buffer.append("  ."+port[p]+" ( " + port[p] + " )," + port_comment[p], cur_num)
            else:
                vim.current.buffer.append("  ."+port[p]+" ( " + port[p] + " )" + port_comment[p], cur_num)
            cur_num = cur_num + 1
        vim.current.buffer.append(");", cur_num)
        # port 对齐
        print str(port_start_num+1) + " " + str(cur_num) 
        vim.command(str(port_start_num+1) + ", " + str(cur_num) + " Align ( ) //")
    else:
        #添加模块名与例化名
        vim.current.buffer.append(mod_name + " " +inst_name+" ( " , cur_num)
        cur_num = cur_num + 1
        #添加port例化
        for p in range(len(port)):
            if(p < len(port) - 1):
                vim.current.buffer.append("  ."+port[p]+" ( " + port[p] + " )," + port_comment[p], cur_num)
            else:
                vim.current.buffer.append("  ."+port[p]+" ( " + port[p] + " )" + port_comment[p], cur_num)
            cur_num = cur_num + 1
        vim.current.buffer.append(");", cur_num)
        # port 对齐
        print str(start_num + 2) + " " + str( cur_num) 
        vim.command(str(start_num + 2) + ", " + str(cur_num)  + " Align ( ) //")
    #vim.current.buffer.append("test line", pos[0])
    #   print vim.current.range 


# 将记录结果添加到当前buffer位置
#vim.command("normal " + "gg")
#vim.command("/module")
#line = vim.current.line
#print(line)
EOF
endfunc


func! ChangeTime()
    call setline(6, "// Last Change Time:    ".strftime("%c"))
endfunc


