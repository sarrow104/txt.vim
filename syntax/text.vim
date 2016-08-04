" Vim syntax file
"       File:	plaintext.vim
"   Language:	plainText file
"      Brief:	Supply Extended Text file edit/view-functionality 
" Maintainer:   sarrow<sarrow104 AT gmail DOT com>
"     Author:   sarrow<sarrow104 AT gmail DOT com>
"    Version:	v1.5
" LastModify:	2008十月23
"
"------------------------------------------------------------
"
" 快捷键规律:							{{{1
" 	<C-...>
" 			一般不修改当前显示的内容。
"
" 	<A-...>
" 			会修改文件内容
"
" Install:							{{{1
"    	1) Copy this file into your $Vimfiles/syntax directory.
"    	2) Add this line below to your .vimrc(*unix) or _vimrc(windows) file: --->
"    	   au BufNewFile,BufRead *.text		setf text
"    	<---
"    	3) 在.vimrc或_vimrc文件中添加
"    	   let g:ChapterNavigatorWindowPostion = 'left' or 'right'
"    	   let g:ChapterNavigatorWindowWidth   = 任意合理的数字
"
"    	  以设定导航窗口的位置以及宽度。导航窗口的默认位置为右侧，默认宽度为35
"    	  							Date:2008十月20
"
"-------------------------------------------------------------
"
" Usage:							{{{1
"	:TSplit   	
"			以textwidth选项来分割长行。
"
"	:TJoin   	
"			以空行为段落标记，把组成某一段的各行合并成一行。
"
"	:TReplaceLeadSpace
"			给非标题行、分割行、属性行外的行的开头添加两个‘　’，
"			即全角空格。
"
"	:TDec2
"			把连续的空行替换为单个空行。
"	:TInc2 		
"			在各行之间添加一个空行为分割。
"
"	:TFormat
"			简单的格式化；如剔除ubb代码，替换掉不能用cp936正常编码
"			的字符（此功能不全，缺少对应的码表）。
"
"	:Text2Html [out_put_dir]
"			Sarrow: 2010年12月21日
"			简单地把文件转化为Html文件——注意，不是vim系统自带的
"			TOhtml风格——完全照搬显示格局，而是类似于VIM.ViKi这样
"			的东西。
"
"-------------------------------------------------------------
"
"	<C-n>	--	跳到下一个章节标题	(next chapter)
"	<C-p>	--	跳到上一个章节标题	(previous chapter)
"
"	g2n
"	g2p
"	        --      在二级标题之间跳转
"			NOTE:单独的p是粘贴命令！10p标示连续粘贴10次！
"
"	tt	-- 	自动识别章节标题，对没有加星号的，加上适当的标示。
"	t1	--	强制加上或者转换为 第一标题级。相当于html中的<h1></h1>
"	t2	--	第二级别的标题
"	tx	--	第x级别的标题，1 <= x <= 6
"	t6	--	第六级标题
"	t+	--	增加标题级别
"	t-	--	降低标题级别
"
"-------------------------------------------------------------
"
"TODO
"	cs	--	Change content between mack “”
"
"TODO
"	<Tab>
"	<S-Tab> --	在链接之间跳转
"			（仿照Opera浏览器，<A-Left>返回；<A-Right>下一张。
"			<BackSpace>回到上级目录，等等）。
"			链接|\%(PREV\|NEXT\|LINK\|INDEX\|UP\|HOME\):.\{-1,}|
"			分别表示"向前","向后","一般链接","目录","向上","主页"
"TODO
"		--	可以在NavigatorWindow上增加一个信息显示——显示出当前
"			章节的阅读量的信息——本章节有说少行，距离标题行又有
"			多少行，以及两者的百分比。
"TODO
"	:HiQuote--	高亮“”、‘’及其内的文字。
"			反之，关闭该高亮。
"
"TODO 2010-12-19
"	参考Tlist插件，把CC的章节浏览窗口，做成singelton形式——即，同时只能有
"	一个章节窗口
"
"--------------------------------------------------------------
"
"	<A-s>2	--	插入大分章节行（70个=字符）
"	<A-s>1	--	插入小分章节行（70个-字符）
"
"	:CC	--	用自定义函数实现的章节列表功能——打开/关闭章节列表窗
"			（or导航窗口）
"			（熟记法：CC - Chapter title Create / Close）
"			SubUtility:
"			<C-l>
"				当前章节的定位，以及窗口的跳转。
"				第二次按，则跳回来。
"				Sarrow:2009-07-27
"				加入 "在跳转的同时，如果需要，将更新章节列表" 的功能
"
"				另外，在编辑文本后，光标停止 updatetime 长的时
"				间后，章节列表会自动更新。&updatetime 的默认值
"				为2000，即2秒。
"
"			<Enter>
"				在导航窗口中，可以直接跳到浏览窗口中对于的标题开始处
"
"			:CUpdate
"				更新导航窗口内的章节标题列表；但是不切换窗口
"			
"			K	to the first 兄弟  
"			J	to the last  兄弟
"			P	to the father node
"			n       to the next sibling
"			p       to the previous sibling
"				Sarrow:2009-06-24
"
"			TODO
"				TextChapterList.refactoring
"					重构，重新设计内部实现，把相同的子功能
"					尽量提取出来，列为单独的函数
"
"				TextChapterList.MoveChapter
"					在章节目录列表中，使用移动功能，可以把
"					结果直接反应在被绑定的的文本上。也就是
"					说，列表这边，看起来只是标题移动了，而
"					另一边则整个章节都被移动了位置。
"
"			TODO:2008十月20
"
"				在已经关闭FileWindow的情况，通过在
"				NavigatorWindow内按<C-l>，重新打开FileWindow并
"				定位到上次阅读的位置。
"
"			TODO:2008十月21
"			OK:
"
"				发现Lower_round中有一个比较严重的bug。
"
"				因为Lower_round其实是用的两端找中间的战术
"				<beg> <cursor> <end>
"				而很多文章的最后一行往往都不是标题行：
"				** Title, bla, bla...
"				在这样的文章中，在最后一个章节内按<C-L>进行窗
"				口跳转，并定位章节的时候，必然会发生溢出错误：
"
"				<last-title-line> <cursor> ...
"
"				解决方法：
"
"				1、在b:TXTChapEntry.linenum后再添加
"				一个数据即可，比如line('$') + 1
"
"				2、或者在s:Lower_round()的开头加一句判断。
"
"			FIXME: 2009-07-27
"			OK:
"
"			        原本是使用的是 bufname来做跳转的。
"			        因此，产生了很多问题——比如 "~"以及 "[]"等符
"			        号的处理，VIM或者vim所处的shell都有可能被赋予
"			        特殊的含义。
"
"			        这样，白白增加了编码难度。
"
"			        然而，使用数字 bufnu 作为 窗口/缓存 的指代，就
"			        会方便很多。
"
"			FIXME:                                                {{{1
"			OK:
"			
"				在使用了导航窗口以后，不能修改当前工作目录，不
"				然会出现多个导航窗口的现象。
"
"			TODO: 2009-07-30
"			OK:
"				auto update view
"
"				autocmd Cursor
"----------------------------------------------------------
"
"1}}}

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

"/第.\{-1,5}集
"viwyO"tto:%s#^"#\*\*\*#g

"/^卷\S\{-1,5}\s
"veeyO"tto:%s#^"#\*\*\*#g

"/^第.\{-1,5}卷\s
"v2t yO"tto:%s#^"#\*\*\*#g

"%s#\([怎什那这多甚]\)　#\1么#g
"%s#\(\n\)\@<!\zs\ze\n　　#\r#g

if !exists("b:match_words")  "{{{1
    let b:match_words = '「:」,［:］,【:】,｛:｝,《:》,『:』,“:”,‘:’,（:）,\(，\|、\):\(。\|？\|！\)'
endif

" Highlight Setting {{{1
"Title
syn match	TextCommand	/^!.\+$/
syn match	TextTitle1	/^\*\{1}\s\+\S.*$/
syn match	TextTitle2	/^\*\{2}\s\+\S.*$/
syn match	TextTitle3	/^\*\{3}\s\+\S.*$/
syn match	TextTitle4	/^\*\{4}\s\+\S.*$/
syn match	TextTitle5	/^\*\{5}\s\+\S.*$/
syn match	TextTitle6	/^\*\{6}\s\+\S.*$/

if !exists('*s:MakeShorCut')
    function s:MakeShorCut(key, val) "{{{1
	exe 'nnoremap <A-s>'.a:key.' I'.a:val.':<ESC>'
	exe 'inoremap <A-s>'.a:key.' '.a:val.':'
	exe 'vnoremap <A-s>'.a:key.' c'.a:val.':<ESC>'
    endfunction
endif

" TODO
" Insert tag/author/date/trackback/from mack {{{1
"silent call s:MakeShorCut('t', 'tag', '标签')
"silent call s:MakeShorCut('u', 'status', '状态')
"silent call s:MakeShorCut('d', 'date', '日期')
"silent call s:MakeShorCut('f', 'from', '出自')
"silent call s:MakeShorCut('m', 'mailto', '电邮')
"silent call s:MakeShorCut('a', 'author', '作者')
"silent call s:MakeShorCut('k', 'trackback', '引自')
"silent call s:MakeShorCut('r', 'rank', '评级')
"silent call s:MakeShorCut('c', 'character', '人物')
"silent call s:MakeShorCut('o', 'translator', '译者')

silent call s:MakeShorCut('t', 'tag')
silent call s:MakeShorCut('u', 'status')
silent call s:MakeShorCut('d', 'date')
silent call s:MakeShorCut('f', 'from')
silent call s:MakeShorCut('m', 'mailto')
silent call s:MakeShorCut('a', 'author')
silent call s:MakeShorCut('k', 'trackback')
silent call s:MakeShorCut('r', 'rank')
silent call s:MakeShorCut('c', 'character')
silent call s:MakeShorCut('o', 'translator')

"let s:it = 1
"while s:it <= 6
"    exe 'syn match	TextTitle'.it.' /^\*\{'.it.'}\s\+\S.*$/'
"    let s:it = s:it + 1
"endwhile
syn match	TextMessage	/^\c\%(status\|状态\|mailto\|by\|rank\|link\|post\|format\|trackback\|author\|作者\|tag\|标签\|from\|时间\|date\|日期\|translator\|翻译\|整理\)\%(:\|：\)/

"URL EMAIL:
syn match txtEmail '\<[A-Za-z0-9_.-]\+@\([A-Za-z0-9_-]\+\.\)\+[A-Za-z]\{2,4}\>\(?[A-Za-z0-9%&=+.,@*_-]\+\)\='
syn match txtUrl   '\<\(\(https\=\|ftp\|news\|telnet\|gopher\|wais\)://\([A-Za-z0-9._-]\+\(:[^ @]*\)\=@\)\=\|\(www[23]\=\.\|ftp\.\)\)[A-Za-z0-9%._/~:,=$@-]\+\>/*\(?[A-Za-z0-9/%&=+.,@*_-]\+\)\=\(#[A-Za-z0-9%._-]\+\)\='
syn match txtUrl   '\<\(file://localhost/\i\+:\=/\)\(?[A-Za-z0-9/%&=+.,@*_-]\+\)\=\(#[A-Za-z0-9%._-]\+\)\='
"syn match txtEmailMsg '^\s*\(From\|De\|To\|Para\|Date\|Data\|Assunto\|Subject\):.*'
"syn match txtEmailQuote '^\(>\($\| \)\)\+'

"Some symbol
syntax match 	WideSpace 	/\zs　\+/
syntax match	TailSpace	display excludenl "\s\+$"
syntax match	SpecialChar	/\(●\|☆\|★\)\1*/
syntax match 	HorizonBar	/^[ 　]*\(◎\|\~\|～\|*\|＊\|-\|－\|+\|＋\|=\|＝\)\1\{3,}$/
syntax match 	ErrorMsg	/\([“”]\)\_[^“”]\{-1,}\1/

" Block Regin
syntax region 	BlockCode matchgroup=BlockMatch 
	    \start=/^\s*#\(Code=\w\S*\>\).\{-}<<\z(.\+\)$/ end=/^\s*\z1\s*$/ contains=ALL
syntax region 	TabledTata matchgroup=BlockMatch 
	    \start=/^\s*#\(Table=\d\+\*\d\+\>\)$/ end=/^\s*\#End$/ contains=ALL
syntax region 	Mathmatic matchgroup=BlockMatch 
	    \start=/^\s*#\(Math\)$/ end=/^\s*\#End$/ contains=ALL

highlight def link	BlockMatch	Identifier
highlight def link	BlockCode	Statement
highlight def link	TabledTata	Statement
highlight def link	Mathmatic	Statement
highlight def link	TailSpace	Underlined

"highlight def link	TextCommand	Underlined
highlight def link	TextCommand	Identifier
highlight def link	TextMessage	Comment
highlight def link	HorizonBar	Type
highlight def link	SpecialChar	PreProc
highlight def link	txtUrl		PreProc

highlight TextTitle1	guifg=aquamarine2	gui=bold
highlight TextTitle2	guifg=#33aaff		gui=bold
highlight TextTitle3	guifg=#3399ee		gui=bold
highlight TextTitle4	guifg=#3388dd		gui=none
highlight TextTitle5	guifg=#3377cc		gui=none
highlight TextTitle6	guifg=#3366bb		gui=none

" Some Inserting Symbol {{{1
" Insert split line mack
nnoremap <A-s>1 o<ESC>70i-<ESC>o<ESC>
nnoremap <A-s>2 o<ESC>70i=<ESC>o<ESC>
vnoremap <A-s>1 c<CR><C-o>70i-<ESC>o<ESC>
vnoremap <A-s>2 c<CR><C-o>70i=<ESC>o<ESC>
inoremap <A-s>1 <CR><C-o>70i-<ESC>o
inoremap <A-s>2 <CR><C-o>70i=<ESC>o

nnoremap <buffer> <2-LeftMouse> :call <SID>Execut_this_line('2-left')<CR>

nnoremap <buffer> <CR> :call <SID>Execut_this_line('cr')<CR>

function! s:Execut_this_line(action)
    let _line_ = getline('.')
    let _pattern = '^!\zs.\+$'
    if _line_ =~ _pattern
	call system#Gui_execut_this(matchstr(_line_, _pattern))
    else
	" simulate double-left-mouse-click
	if a:action == '2-left'
	    normal! viw
	" simulate carrige-return
	elseif a:action == 'cr'
	    normal! 
	endif
    endif
endfunction

function! s:SetTextTitle(val) 	" 把当前行设置为第 a:val 级 标题 {{{1
    if type(a:val) != type(0) || a:val <= 0
	return
    endif
    let line = getline(".")
    if !strlen(line)
	return
    endif
    let line = matchstr(line, '^\%(\*\+\s\+\)\=\zs.\+$')

    let line = matchstr(line, '^\%(\s\|　\)*\zs.\+$')
    
    let line = repeat('*', a:val).' '.line
    call setline(".", line)
endfunction

function! s:GetTitleLeval(line) 	" 按标记，获得把当前行的标题级别 {{{1
    return strlen(matchstr(a:line, '^\*\+\%(\ \)\@='))
endfunction

function! s:TextAutoTitle()	" Auto detect titel level, and mark it! {{{1
    let level = 0
    if line(".") == 1
	let level = 1
    else
	"let line = matchstr(getline("."), '^[\ \t　]*\zs.\+$')
	let line = getline(".")
	let line = matchstr(line, '^\%(\*\+\s\+\)\=\zs.\+$')
	let line = substitute(line, '　', ' ', 'ge')
	let line = matchstr(line, '^\s*\zs.\+$')
	let line = matchstr(line, '^\zs.\{-}\ze\s*$')
	"let line = substitute(line, '\s\+', '_', 'ge')
	"[\ \t　]
	if !strlen(line)
	    return
	end

	let line = '.'.line
	while line =~ '^\.\d\+'
	    let level = level + 1
	    let line = matchstr(line, '^\.\d\+\zs.\+$')
	endwhile
	let level = (level == 0 ? 2 : level + 1)
    endif
    call <SID>SetTextTitle(level)
endfunction

function! s:TextTitleInc() "Increase Current Chapter Title Level by ONE {{{1
    let level = s:GetTitleLeval(getline("."))
    if level < 6
	let level = level + 1
    endif
    call <SID>SetTextTitle(level)
endfunction

function! s:TextTitleDec() "Decrease Current Chapter Title Level by ONE {{{1
    let level = s:GetTitleLeval(getline("."))
    if level > 0
	let level = level - 1
    endif
    call <SID>SetTextTitle(level)
endfunction

"============== Transfer Global Settings ================== {{{1
if exists("g:ChapterNavigatorWindowPostion") && type(g:ChapterNavigatorWindowPostion) == type("")
    let s:ChapterNavigatorWindowPostion = g:ChapterNavigatorWindowPostion == 'right' ? 'botright' : 'topleft'
else
    let s:ChapterNavigatorWindowPostion = 'botright'
endif

if exists("g:ChapterNavigatorWindowWidth") && type(g:ChapterNavigatorWindowWidth) == type(0)
    let s:ChapterNavigatorWindowWidth = g:ChapterNavigatorWindowWidth
else
    let s:ChapterNavigatorWindowWidth = 35
endif

function! s:Lower_round(line_nums, here) "Find the Lowest position, where `here' is not smaller than {{{1
    " C++ 的std::lower_bound算法不适合此处，因为该算法求出的是插入位置。

    " BugFix:
    " Author:sarrow:
    "   Date:2008十月21
    " 加入下行代码，以改掉一个bug(此bug的详细说明见头部)，以防止调用Lower_round时可能发生的溢出错误。

    if 0 > a:here
	return 0
    elseif a:line_nums[-1] < a:here
	return len(a:line_nums) - 1
    endif

    let _first = 0
    let _len = len(a:line_nums)
    let _last = _first + _len 
    while _len > 0
	let _half = _len / 2
	let _mid = _first + _half

	if a:line_nums[_mid] < a:here
	    let _first = _mid + 1
	    let _len = _len - _half - 1
	else
	    let _len = _half
	endif
    endwhile
    "2008十月18
    "此处对std::lower_bound修改了少许，以适应本函数的需要
    if a:line_nums[_first] > a:here
	let _first = _first - 1
    endif
    return _first
endfunction

function! s:GetChapEntryBufName() "Use current file name path, to create a correspond Entry List file name {{{1
    " TODO
    " 应该和Tlist一样，值保留一个ChapList 窗口(buffer也唯一)
    " 就是说，我需要一个全局变量来保存该buffer的值(窗口编号则不一定。)
    " 当然，其BufName也应该是唯一的。
    " return 'ChapList >'.escape(expand("%:p"),'[]~')
    "return 'ChapList>' . winbufnr(0)
    " Sarrow: 2010年12月26日
    return 'ChapList>'
endfunction

"function! s:DrawNavigatorWindow() {{{
if !exists("*s:DrawNavigatorWindow")
    function s:DrawNavigatorWindow()
	setlocal modifiable
	silent %delete _
	silent 0put = b:TXTChapEntry.chapter
	call s:NaviWindowBufSetting()
	let &modified=0
	setlocal nomodifiable
    endfunction
endif

"function! s:OpenNaviWindow() {{{1
if !exists("*s:OpenNaviWindow")
    function s:OpenNaviWindow()
	if !bufexists(b:TXTChapEntry['navi_bn'])
	    echoe 'Error: buf "navigat window" not exist'
	    return
	endif
	"let navi_bn = b:TXTChapEntry['navi_bn']
	silent! execute s:ChapterNavigatorWindowPostion . ' vertical ' .
		    \ string(s:ChapterNavigatorWindowWidth) . ' new ' . s:GetChapEntryBufName()
	"execute 'buffer ' . navi_bn
    endfunction
endif

if !exists("*s:UnfoldView")
    function! s:UnfoldView(lnr)
	" locate a:lnr in current buffer
	execute a:lnr
	" Unfold, then middle of window
	normal zvzz
    endfunction
endif

if !exists("*s:SwitchWnd")
    function! s:SwitchWnd(w_nr)
	exe a:w_nr.'wincmd w'
    endfunction
endif

function! s:GetChapterEntryList()      "{{{1
    " TXTCreateSharedData
    " 2008-10-17
    " 把跳转表建立在buffer内，就是说和当前阅读的文本是捆绑在一起的。
    let Ret = {'chapter': [], 'linenum': [],
		\ 'navi_bn': bufnr(s:GetChapEntryBufName(), bufnr(s:GetChapEntryBufName()) == -1),
		\ 'file_bn': winbufnr(0),
		\ 'chap_idx': 0,
		\ 'changedtick': b:changedtick,
		\ 'corsur': line('.')}
    let g:current_file_bn = Ret['file_bn']

    " Sarrow:2010-11-04
    " 关于 window_number 与 buffer_number
    " 注意，buffer_number可能对应多个window_number！特别是在split的情况下！
    " 这时，如何跳转就成了问题！ 
    function Ret.IsNaviWnd() dict
	return self['navi_bn'] == winbufnr(0)
    endfunction

    function Ret.IsFileWnd() dict
	return self['file_bn'] == winbufnr(0)
    endfunction

    function Ret.DeletNaviBuf() dict
	silent execute 'bdelete ' . self['navi_bn']
    endfunction

    function Ret.DeletFileBuf() dict
	silent execute 'bdelete ' . self['file_bn']
    endfunction

    function Ret.NaviWndNum() dict
	return bufwinnr(self['navi_bn'])
    endfunction

    function Ret.FileWndNum() dict
	return bufwinnr(self['file_bn'])
    endfunction

    function Ret.CloseNaviWnd() dict
	let navi_wnd_num = self.NaviWndNum()
	if navi_wnd_num != -1
	    execute navi_wnd_num . 'wincmd w'
	    silent wincmd q
	endif
    endfunction

    function Ret.GenerateChapList() dict
	if !self.IsFileWnd()
	    echoe 'Error: Can not Gernerate Chapter List out of file window!'
	    return
	endif
	let self['chapter'] = []
	let self['linenum'] = []
	let save_cursor = getpos('.')
	silent! g/^*\+\ /call add(self['chapter'], getline('.')) | call add(self['linenum'], line('.'))
	call setpos('.', save_cursor)
    endfunction

    function Ret.Locate() dict
	if !empty(self['linenum'])
	    let self['chap_idx'] = s:Lower_round(self['linenum'], self['corsur']) + 1
	endif
    endfunction

    function Ret.ChapterLineNum() dict
	if !self.IsNaviWnd()
	    echoe 'Error: Can not retrive chapter line number!'
	    return
	endif
	return self['linenum'][line(".") - 1]
    endfunction

    function Ret.ToFileWnd() dict
	let winnum = self.FileWndNum()
	if winnum == -1
	    echoe 'Error: Can not find file window!'
	    return
	else
	    call s:SwitchWnd(winnum)
	endif
    endfunction

    function Ret.ToNaviWnd() dict
	let winnum = self.NaviWndNum()
	if winnum == -1 "The Chap Entry Window has been Closed
	    call s:OpenNaviWindow()
	    call s:DrawNavigatorWindow()
	else
	    "" If the window is already open, jump to it
	    call s:SwitchWnd(winnum)
	endif
    endfunction

    function Ret.NeedUpdate() dict
	" 由于 b:changedtick 系统变量，只能在处于当前buffer的状态才能读取，因
	" 此，必须先确保处于 FileWindow 下。
	if !self.IsFileWnd()
	    echoerr 'Error: Can not check!'
	    return
	endif
	" Sarrow: 2011-03-18
	return g:current_file_bn != self['file_bn'] || b:changedtick != self['changedtick']
	" End:
	"return b:changedtick != self['changedtick']
    endfunction

    function Ret.AutoUpdate() dict
	if !self.IsFileWnd()
	    echoerr 'Error: Can not check and update Chapter List out of file window!'
	    return
	endif
	if self.NeedUpdate()
	    call self.GenerateChapList()
	    let self['changedtick'] = b:changedtick
	    let g:current_file_bn = self['file_bn']
	endif
	let self['corsur'] = line('.')
	call self.Locate()
	call setbufvar(self['navi_bn'], 'TXTChapEntry', self)
    endfunction

    function Ret.CloseFileWnd() dict
    endfunction

    " =============================
    "call Ret.AutoUpdate()

    call Ret.GenerateChapList()
    call Ret.Locate()
    return Ret
endfunction

"function! s:JumpIntoFile{{{1
if !exists("*s:JumpIntoFile") 
    function s:JumpIntoFile()
	if !b:TXTChapEntry.IsNaviWnd()
	    return
	endif
	if foldclosed(line('.')) > 0
	    normal zvzz
	    return
	endif
	let line_num = b:TXTChapEntry.ChapterLineNum()
	call b:TXTChapEntry.ToFileWnd()
	execute line_num
    endfunction
endif

"function! s:ChapEntryFileFoldMethod(lnum) {{{1
if !exists("*s:ChapEntryFileFoldMethod") 
    function s:ChapEntryFileFoldMethod(lnum)
	return s:GetTitleLeval(getline(a:lnum)) 
    endfunction
endif

"function! s:NaviWindowBufSetting() {{{1
if !exists("*s:NaviWindowBufSetting")
    function s:NaviWindowBufSetting()
	setlocal winfixwidth

	"throwaway buffer options
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal nowrap
	setlocal foldcolumn=0
	setlocal nobuflisted
	setlocal nospell

	setlocal foldmethod=expr
	setlocal foldexpr=<SID>ChapEntryFileFoldMethod(v:lnum)
	setlocal foldlevelstart=1
	setlocal cursorline
	setlocal nonumber

	"setlocal filetype=txt
	syn match	TextTitle1	/^\*\{1}\s\+\S.*$/
	syn match	TextTitle2	/^\*\{2}\s\+\S.*$/
	syn match	TextTitle3	/^\*\{3}\s\+\S.*$/
	syn match	TextTitle4	/^\*\{4}\s\+\S.*$/
	syn match	TextTitle5	/^\*\{5}\s\+\S.*$/
	syn match	TextTitle6	/^\*\{6}\s\+\S.*$/
    endfunction
endif

" Sarrow: 2011-03-18
" 检查是否更新Navigation Window。
" 仅用于FileWindow
"   当切换buffer时，利用autocmd延时调用。
function! s:CheckAndUpdateNaviWnd()
    if !exists('g:current_file_bn')
	return
    endif
    if !exists('b:TXTChapEntry')
	let need_redraw = 1
	let b:TXTChapEntry = s:GetChapterEntryList()
    endif
	
    if bufwinnr(b:TXTChapEntry['navi_bn']) != -1
	call <SID>FileChapEntryListLocate(0)
    endif
endfunction

augroup TXTChapEntry
    " FIXME 2011-03-18
    " 非常奇怪，当我切换到另一个txt文本的时候，这个autocmd会失效。
    au!
    autocmd CursorHold	<buffer>	 call <SID>CheckAndUpdateNaviWnd()
    "autocmd BufWinLeave	<buffer> 	 call <SID>OnExit()
    autocmd BufDelete	<buffer> 	 call <SID>OnExit()
augroup END

" Sarrow: 2011-03-18
nnoremap <buffer> <silent>	<C-l>		:call <SID>FileChapEntryListLocate(1)<CR>
function! s:KeyMap_of_FileWnd()
    " Jumping Around:
    " Needed:?
    "nnoremap <buffer> <silent>	<C-j>		:call <SID>LocateNextSibling()<CR>
    "nnoremap <buffer> <silent>	<C-k>		:call <SID>LocatePrevSibling()<CR>
    command! -buffer -nargs=0 	Locate		 call <SID>FileChapEntryListLocate(1)
    command! -buffer -nargs=0 	CUpdate		 call <SID>FileChapEntryListLocate(0)
    " NOTE: 若没有 bdelete ，又重复性地调用本函数，以至于添加下面两个 autocmd
    " 的话，并不会导致之前的被覆盖——vim系统会重复调用它们，添加多少次，那么
    " ，条件符合的时候，就调用多少次。
    " 因此，一般是把 autocmd 包在一个 group 里面，然后整体销毁、整体赋值
    " "updatetime" is used by CursorHode,CursorMoved, etc.
    setlocal updatetime=2000
endfunction

" function! s:ToggleChapgerEntryList()  "{{{1
if !exists("*s:ToggleChapgerEntryList")
    function s:ToggleChapgerEntryList()
	" Sarrow: 2010年12月26日
	" FIXME 2011-03-18
	augroup TXTChapEntry_Toggle
	    au!
	    autocmd WinLeave *.text    let g:TXT_navi_pre_bufnr = winbufnr(0)
	augroup END
	" End:

	if !exists('b:TXTChapEntry')
	    let need_redraw = 1
	    let b:TXTChapEntry = s:GetChapterEntryList()
	endif

	if exists("b:TXTChapEntry") && b:TXTChapEntry.NaviWndNum() != -1
	    call b:TXTChapEntry.CloseNaviWnd()
	    return
	endif

	" bd used on navi_window
	if !buflisted(b:TXTChapEntry['navi_bn'])
	    let need_redraw = 1
	endif

	if b:TXTChapEntry.NeedUpdate()
	    let need_redraw = 1
	endif

	call b:TXTChapEntry.AutoUpdate()

	"if exists('need_redraw')
	    call s:KeyMap_of_FileWnd()
	"endif

	call s:OpenNaviWindow()

	if exists('need_redraw')
	    call s:DrawNavigatorWindow()
	endif

	call s:UnfoldView(b:TXTChapEntry['chap_idx'])

	if exists('need_redraw')
	    call s:KeyMap_of_NaviWnd()
	endif
    endfunction
endif

" function! s:FileChapEntryListLocate() Locate the current Chapter in reading {{{1
" [in]
" 	1	updata and switch window
" 	0	updata and no-switch window
if !exists("*s:FileChapEntryListLocate")
    function s:FileChapEntryListLocate(switch)
	if &ft == 'text' && !exists("b:TXTChapEntry") " Have not yet create the Chap Entry List.
	    let b:TXTChapEntry = s:GetChapterEntryList()
	    let is_need_update = 1
	    " return
	endif

	let pre_is_NaviWindow = 0
	if b:TXTChapEntry.IsNaviWnd()
	    let pre_is_NaviWindow = 1
	    call b:TXTChapEntry.ToFileWnd()
	endif

	" Update Internal Data If Needed:
	if b:TXTChapEntry.NeedUpdate()
	    let is_need_update = 1

	    echohl WarningMsg
	    echomsg 'NOTE: updating navigating Window data!'
	    echohl None
	    "Sarrow:2009-07-28
	    "NOTE: 针对 List ，如果使用 [:] 来赋值，那么，将对被该变量引用的 List 对象，做直接修改
	    "这样，就能影响到所有引用到这个对象的 "变量" 了。
	endif
	if !buflisted(b:TXTChapEntry['navi_bn'])
	    let re_key_mapping = 1
	endif
	call b:TXTChapEntry.AutoUpdate()

	" need jump to Navigate window
	call b:TXTChapEntry.ToNaviWnd()
	if exists('is_need_update')
	    call s:DrawNavigatorWindow()
	endif

	if exists('re_key_mapping')
	    call s:KeyMap_of_NaviWnd()
	endif

	call s:UnfoldView(b:TXTChapEntry['chap_idx'])

	" 回到键入:CUpdate命令的初始窗口 if needed
	if a:switch == pre_is_NaviWindow
	    call b:TXTChapEntry.ToFileWnd()
	endif
    endfunction
endif

function! s:KeyMap_of_NaviWnd()
    "" NOTE:
    " Put some key maping here!
    " Jumping Around:
    nnoremap <buffer> <silent> <CR> 		:call <SID>JumpIntoFile()<CR>
    nnoremap <buffer> <silent> <2-LeftMouse>	:call <SID>JumpIntoFile()<CR>

    nnoremap <buffer> <silent>	<C-l>  		:call <SID>FileChapEntryListLocate(1)<CR>
    command! -buffer -nargs=0 	Locate  	 call <SID>FileChapEntryListLocate(1)
    command! -buffer -nargs=0 	Locate 		 call <SID>FileChapEntryListLocate(1)

    " Move Within Navigating Window:
    "" last 兄弟
    nnoremap <buffer> <silent> K 		:call <SID>LocateFirstSibling()<CR>
    "" first 兄弟
    nnoremap <buffer> <silent> J 		:call <SID>LocateLastSibline()<CR>
    "" parent
    nnoremap <buffer> <silent> P 		:call <SID>LocateParent()<CR>

    "" previous-sibling
    nnoremap <buffer> <silent> p 		:call <SID>LocatePrevSibling()<CR>zvzz
    "" next-sibling
    nnoremap <buffer> <silent> n 		:call <SID>LocateNextSibling()<CR>zvzz

    " visual-version
    vnoremap <buffer> <silent> K 	   <ESC>:call <SID>LocateFirstSibling()<CR>m'gv''
    vnoremap <buffer> <silent> J 	   <ESC>:call <SID>LocateLastSibline()<CR>m'gv''
    vnoremap <buffer> <silent> P 	   <ESC>:call <SID>LocateParent()<CR>m'gv''

    " Window Menu:
    " First Open Entry List Navigator Window, Second close it. 
    command! -buffer -nargs=0	CC 		call <SID>ToggleChapgerEntryList()
    command! -buffer -nargs=0 	CUpdate 	call <SID>FileChapEntryListLocate(0)
endfunction

" First Open Entry List Navigator Window, Second close it. 
command! -buffer -nargs=0		CC 	call <SID>ToggleChapgerEntryList()
",BufDelete,BufWipeout,BufWinLeave

" on close window or delete buffer
function! s:OnExit()
    if exists('b:TXTChapEntry')
	"call b:TXTChapEntry.DeletNaviBuf()
    endif
    if exists('b:TXTChapEntry')
	call b:TXTChapEntry.DeletFileBuf()
	augroup TXTChapEntry
	    au!
	augroup END
    endif
endfunction

" NOTE: a:minus must be 0 or above!
function! s:GetIndentWith(minus)
    let cur_indent = s:ChapEntryFileFoldMethod(line('.'))
    if cur_indent >= a:minus
	let cur_indent -= a:minus
    endif
    return cur_indent
endfunction

function! s:LocateFirstSibling()
    let pattern = '^\*\{-0,'. string(s:GetIndentWith(1)) . '}\( \|$\)\@=' 
    if search(pattern, 'bc') > 0
	normal j
    endif
endfunction
function! s:LocateLastSibline()
    let pattern = '^\*\{-0,'. string(s:GetIndentWith(1)) . '}\( \|$\)\@=' 
    if search(pattern, 'c') > 0
	normal k
    endif
endfunction
function! s:LocateParent()
    let pattern = '^\*\{-0'. string(s:GetIndentWith(1)) . '}\( \|$\)\@=' 
    call search(pattern, 'bc')
endfunction
function! s:LocatePrevSibling()
    let pattern = '^\*\{'. string(s:GetIndentWith(0)) . '}\( \|$\)\@=' 
    normal 0
    call search(pattern, 'b')
endfunction
function! s:LocateNextSibling()
    let pattern = '^\*\{'. string(s:GetIndentWith(0)) . '}\( \|$\)\@=' 
    normal 0
    call search(pattern)
endfunction
"=================== some key maping ==================== {{{1
nnoremap <buffer> tt :call <SID>TextAutoTitle()<CR>

nnoremap <buffer> t1 :call <SID>SetTextTitle(1)<CR>
nnoremap <buffer> t2 :call <SID>SetTextTitle(2)<CR>
nnoremap <buffer> t3 :call <SID>SetTextTitle(3)<CR>
nnoremap <buffer> t4 :call <SID>SetTextTitle(4)<CR>
nnoremap <buffer> t5 :call <SID>SetTextTitle(5)<CR>
nnoremap <buffer> t6 :call <SID>SetTextTitle(6)<CR>

nnoremap <buffer> t+ :call <SID>TextTitleInc()<CR>
nnoremap <buffer> t- :call <SID>TextTitleDec()<CR>

" Push-front two chinese white-space characters
nnoremap <buffer> <C-q>  :let _hls=&hls<CR>:set nohls<CR>:let __X__=@/<CR>:silent s#^[\ \t　]*#　　#g<CR>:let @/=__X__<CR>:let &hls=_hls<CR>
inoremap <buffer> <C-q>  <C-r>='　　'<CR>

" Combine to the 1st none emty line, and strip chinese white-space characters
" between them, if any.
" s#\n\+[\ \t　]*##g
" nnoremap <buffer> <C-J>  mz:let __X__=@/<CR>$:silent s#\%([^\n]\)\@=\n\+[\ \t　]*##g<CR>`z:let @/=__X__<CR>
" inoremap <buffer> <C-J>  <C-o>mz<C-o>$<C-o>:silent s#\%([^\n]\)\@=\n\+[\ \t　]*##g<CR><C-o>`z<C-o>:let @/=''<CR>

nnoremap <buffer> <C-J>  mz:let __X__=@/<CR>$:silent s#\n\+[\ \t　]*##g<CR>`z:let @/=__X__<CR>
inoremap <buffer> <C-J>  <C-o>mz<C-o>$<C-o>:silent s#\n\+[\ \t　]*##g<CR><C-o>`z<C-o>:let @/=''<CR>

" Format
nnoremap <buffer> <A-f>	 gq}``
nnoremap <buffer> <A-F>	 gq{``

" Delete text blockly
nnoremap <buffer> <A-d>	 d}
nnoremap <buffer> <A-D>	 d{

call pairpunct#PairAdd_chinese_style()

call pairpunct#PairVisual_chinese_style()

" Sarrow:2009-07-26
" Old:
" nnoremap <buffer> <silent> gn $/^\*\{1,6}\s<CR>
" nnoremap <buffer> <silent> gp 0?^\*\{1,6}\s<CR>
" nnoremap <buffer> <silent> g2n $/^\*\{2}\s<CR>
" nnoremap <buffer> <silent> g2p 0?^\*\{2}\s<CR>

" vnoremap <buffer> <silent> gn $/^\*\{1,6}\s<CR>
" vnoremap <buffer> <silent> gp 0?^\*\{1,6}\s<CR>
" vnoremap <buffer> <silent> g2n $/^\*\{2}\s<CR>
" vnoremap <buffer> <silent> g2p 0?^\*\{2}\s<CR>
" New:
nnoremap <buffer> <silent> <C-n>	:silent call search('^\*\{1,6}\s')<CR>
nnoremap <buffer> <silent> <C-p>	:silent call search('^\*\{1,6}\s', 'b')<CR>
nnoremap <buffer> <silent> g2n		:silent call search('^\*\{2}\s')<CR>
nnoremap <buffer> <silent> g2p		:silent call search('^\*\{2}\s', 'b')<CR>

vnoremap <buffer> <silent> <C-n>	<ESC>:silent call search('^\*\{1,6}\s')<CR>m'gv''
vnoremap <buffer> <silent> <C-p>	<ESC>:silent call search('^\*\{1,6}\s', 'b')<CR>m'gv''
vnoremap <buffer> <silent> g2n		<ESC>:silent call search('^\*\{2}\s')<CR>m'gv''
vnoremap <buffer> <silent> g2p		<ESC>:silent call search('^\*\{2}\s', 'b')<CR>m'gv''
" End:

function! s:MarkAsXY(line1, line2)
    execute a:line1
    normal mx
    execute a:line2
    normal my
endfunction

function! s:TrimTrailingSpaces(line1, line2)	"{{{1
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys/\(\s\|　\)\+$//ge
    normal g,
endfunction
command! -nargs=0 -range=% -buffer TTrimRightSpaces   	call <SID>TrimTrailingSpaces(<line1>,<line2>)

function! s:TextReplaceLeadSpace(line1,line2)	"{{{1
    "TODO:return to original position
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys/^\%(\s\|　\)\{0,}\%(\(◎\|\~\|～\|*\|＊\|-\|－\|+\|＋\|=\|＝\)\1\{3,}\|\*\+\s\|$\|\%(status\|状态\|mailto\|by\|rank\|link\|post\|format\|trackback\|author\|作者\|tag\|标签\|from\|时间\|date\|日期\|translator\|翻译\|整理\)\%(:\|：\)\)\@!/　　/ge
    normal g,
endfunction
command! -nargs=0 -range=% -buffer TReplaceLeadSpace 	call <SID>TextReplaceLeadSpace(<line1>,<line2>)

function! s:TextJoin(line1, line2)	"{{{1
    "TODO:return to original position
    "silent g/^.\{1,}$/,/\n\(^$\)\@?/join

    let _start_line_ = line('.')
    call s:MarkAsXY(a:line1, a:line2)
    "call s:SelectBetween(a:line1, a:line2)
    "silent execute a:line1.','.a:line2.'g/^.\{1,}$/,/^$/join'
    silent 'x,'yg/^.\{1,}$/,/^$/join
    silent 'x,'ys/\(\s\|　\)\+$//ge
    silent 'x,'ys/\(\n\)\@<!\n\(\n\)\@!/\r\r/ge

    let _new_line_ = max([a:line1, _start_line_])
    let _new_line_ = min([_new_line_, line('$')])
    execute 'normal '._new_line_.'G'

endfunction
command! -nargs=0 -range=% -buffer TJoin   	call <SID>TextJoin(<line1>, <line2>)

function! s:TextSplit(line1, line2)	"{{{1
    "TODO:return to original position
    execute 'normal! '
    let _start_line_ = line('.')
    execute 'normal! '.a:line1.'Ggq'.(a:line2-a:line1).'j'
    " return to the position where region start
    " to goto the position where first change happen, use 'g,'
    let _new_line_ = max([a:line1, _start_line_])
    let _new_line_ = min([_new_line_, line('$')])
    execute 'normal '._new_line_.'G'
endfunction
command! -nargs=0 -range=% -buffer TSplit   	call <SID>TextSplit(<line1>, <line2>)

function! s:TextDec2NL(line1, line2)	"{{{1
    "TODO:return to original position
    call s:MarkAsXY(a:line1, a:line2)
    "call s:SelectBetween(a:line1, a:line2)
    silent 'x,'ys/\(\(\s\|　\)*\n\)\{3,}/\r\r/ge
endfunction
command! -nargs=0 -range=% -buffer TDec2 	call <SID>TextDec2NL(<line1>, <line2>)

function! s:TextInc2NL(line1, line2)	"{{{1
    "TODO:return to original position
    call s:MarkAsXY(a:line1, a:line2)
    "call s:SelectBetween(a:line1, a:line2)
    silent 'x,'ys/\(\n\)\@<!\n\(\n\)\@!/\r\r/ge
endfunction
command! -nargs=0 -range=% -buffer TInc2 	call <SID>TextInc2NL(<line1>, <line2>)

function! s:TextFormat(line1, line2) "{{{1
    call s:MarkAsXY(a:line1, a:line2)
    "call s:SelectBetween(a:line1, a:line2)
    silent 'x,'ys#[\.。．·]\{2,}#……#ge
    silent 'x,'ys#»#>>#ge
    silent 'x,'ys#«#<<#ge
    silent 'x,'ys#﹐#，#ge
    silent 'x,'ys#｢#「#ge
    silent 'x,'ys#｣#」#ge
    silent 'x,'ys#“#“#ge
    silent 'x,'ys#”#”#ge
    silent 'x,'ys#¸#，#ge
    silent 'x,'ys#•#·#ge
    silent 'x,'ys##　#ge
    silent 'x,'ys#‧#·#ge
    silent 'x,'ys#‧#·#ge
    silent 'x,'ys#�#　#ge
    silent 'x,'ys#〜#～#ge
    silent 'x,'ys#°#—#ge
    silent 'x,'ys#︰#：#ge
    silent 'x,'ys#┅#…#ge
    " clear'<,'>UBB code
    silent 'x,'ys#\[/\(u\|i\|b\|email\|font\|size\|color\|url\|align\)\]##ge
    silent 'x,'ys#\[\(u\|i\|b\|email\|font=[^\]]\{-1,}\|size=\d\+\%(pt\|px\)\=\|color=[^\]]\{-1,20}\|url=[^\]]\+\|align=\%(right\|center\|left\)\)\]##ge
endfunction
command! -nargs=0 -range=% -buffer TFormat	call <SID>TextFormat(<line1>, <line2>)

"Sarrow: 2011-03-19
function! s:HalfPunct2FullPunct(line1, line2) "{{{1
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys#\.\{2,}#……#ge
    "Sarrow: 2011-03-26
    silent 'x,'ys#[^\da-zA-Z]\zs\.\ze[^\da-zA-Z]#。#ge
    "End:
    silent 'x,'ys#:#：#ge
    silent 'x,'ys#,#，#ge
    silent 'x,'ys#;#；#ge
    silent 'x,'ys#?#？#ge
    silent 'x,'ys#!#！#ge
endfunction
command! -nargs=0 -range=% -buffer TPunctHalf2Full	call <SID>HalfPunct2FullPunct(<line1>, <line2>)

"Sarrow: 2011-05-01
function! s:FullPunct2HalfPunct(line1, line2) "{{{1
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys#…\+#...#ge
    "Sarrow: 2011-03-26
    silent 'x,'ys#。#.#ge
    "End:
    silent 'x,'ys#“\|”#"#ge
    silent 'x,'ys#：#:#ge
    silent 'x,'ys#，#,#ge
    silent 'x,'ys#；#;#ge
    silent 'x,'ys#？#?#ge
    silent 'x,'ys#！#!#ge
endfunction

command! -nargs=0 -range=% -buffer TPunctFull2Half	call <SID>FullPunct2HalfPunct(<line1>, <line2>)

function! s:AlphNumFull2Half(line1, line2) "{{{1
    "encoding=utf-16
    "   :%s`[\ua3b0-\ua3b9\ua3c1-\ua3da\uz3e1-\ua3fa]`\=nr2char(char2nr(submatch(0))-0xa380)`g
    "encoding=utf-8
    "   :%s`[\uff10-\uff19\uff21-\uff3a\uff41-\uff5a]`\=nr2char(char2nr(submatch(0))-0xfee0)`g
    if &encoding != 'utf-8'
        call msg#ErrorMsg('must under utf-8 vim system encoding setting!')
        return
    endif
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys`[\uff10-\uff19\uff21-\uff3a\uff41-\uff5a]`\=nr2char(char2nr(submatch(0))-0xfee0)`g
endfunction

function! s:AlphNumHalf2Full(line1, line2) "{{{1
    if &encoding != 'utf-8'
        call msg#ErrorMsg('must under utf-8 vim system encoding setting!')
        return
    endif
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'ys`[\u0030-\u0039\u0061-\u007a\u0041-\u005a]`\=nr2char(char2nr(submatch(0))+0xfee0)`g
endfunction

command! -nargs=0 -range=% -buffer TAlphNumFull2Half    call <SID>AlphNumFull2Half(<line1>, <line2>)
command! -nargs=0 -range=% -buffer TAlphNumHalf2Full    call <SID>AlphNumHalf2Full(<line1>, <line2>)

function! s:DelEmptyLines(line1, line2) "{{{1
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'yg#^\s*$#d
endfunction

command! -nargs=0 -range=% -buffer TDelEmptyLine	call <SID>DelEmptyLines(<line1>, <line2>)
"End: 2011-03-19

" Sarrow: 2016-06-10
command! -nargs=0 -range=% -buffer TCopyIpadYoukuLink   call <SID>CopyIpadYoukuLink(<line1>, <line2>)
" 将youku视频链接，转换为ipad点击，即可在youku app上播放的链接；

function! s:CopyIpadYoukuLink(line1, line2) " {{{1
    let s:youku_vid = []
    call s:MarkAsXY(a:line1, a:line2)
    let l:line = a:line1
    while l:line <= a:line2
        let vid = matchstr(getline(l:line), '\<http://v\.youku\.com/v_show/id_\zs\w\+==\ze\.html\>')
        if len(vid) > 0
            call add(s:youku_vid, 'http://iosport.youku.com/ipad/ulink?vid='.vid)
        endif
        let l:line += 1
    endwhile
    if len(s:youku_vid) > 0
        call setreg('+', join(s:youku_vid, "\n"))
    endif
endfunction

function! s:Clear_qidian_stamp(line1, line2) "{{{1
    call s:MarkAsXY(a:line1, a:line2)
    silent 'x,'yg#^第.\{-1,5}章#normal t3
    silent 'x,'ys#^更新\(时间\)：\=\(\S\+\).\+$#\1：\2#ge
    silent 'x,'ys#起..点..中..文..网..授权发布##ge
    silent 'x,'ys#好书尽在www.cmfu.com\n##ge
    silent 'x,'ys#\(\s\|　\)\+$##ge
　　silent 'x,'ys/^[　 ]*(\%(起..点..中..文..网\)\?更新\(时间：\S\+\).\+$/\1/ge
    silent 'x,'ys/^　　<a href=http:\/\/www.qidian.com>起点中文网\s*www.qidian.com\s*欢迎广大书友光临阅读，最新、最快、最火的连载作品尽在起点原创！<\/a>\n//ge
endfunction
command! -nargs=0 -range=% -buffer ClearQidianStamp	call <SID>Clear_qidian_stamp(<line1>, <line2>)

function! s:Text2Html(line1, line2, _cwd_)	"{{{1
    echohl WarningMsg
    echomsg a:_cwd_
    echohl None
    let _out_put_dir_ = '.'
    if isdirectory(a:_cwd_)
	let _out_put_dir_ = substitute(a:_cwd_, '[\\/]$', '', 'g')
    endif
    let _of_ = _out_put_dir_ .'/'.fnamemodify(expand('%'), ':p:t:r').'.htm'
    normal gg/^\* /
    let _title_ = getline('.')
    let _title_ = matchstr(_title_, '^\%(\*\+\s\+\)\=\zs.\+$')
    let _title_ = matchstr(_title_, '^\%(\s\|　\)*\zs.\+$')

    let _fenc_table_={'cp936': 'GB2312', 'utf-8': 'utf-8'}
    let _htm_file_encding_ = &fenc
    if has_key(_fenc_table_, &fenc)
	let _file_encoding_ = _fenc_table_[&fenc]
    else
	let _file_encoding_ = 'utf-8'
    endif
    let _time_=strftime('%Y-%m-%d')
    let _email_='sarrow104@gmail.com'
    let s:_ch_name_tbl_=[]
    let s:_stems_ = []

    let _tmp_=@"
    normal ggyG
    execute 'new '._of_
    let &fileencoding=_htm_file_encding_
    " if "_of_" is not empty! first clear it to black-hole registers
    %d_
    " Sarrow: 2010-12-19
    normal P
    let @"=''
    silent %s#&#\&amp;#ge
    silent %s#<#\&lt;#ge
    silent %s#>#\&gt;#ge
    "silent %s#^\(\*\+\)\s\+\(\S.\+\)$#\='<h'.strlen(submatch(1)).'>'.submatch(2).'</h'.strlen(submatch(1)).'>'#ge
    " Sarrow: dot move below line above!
    silent %s# \{2}#\=repeat('&nbsp;', strlen(submatch(0)))#ge
    silent %s/^\(\*\+\)\s\+\(\S.\+\)$/\=s:HTML_Make_title()/ge
    silent %s#^!\(.\+\)$#\='<a href="'.substitute(substitute(submatch(1),' ', '%20', 'g'), '\', '/', 'g').'">'.submatch(0).'</a>'#ge

    " tab-line => blockquote
    silent %s#^\t\+\([^<].*\)$#<blockquote>\1</blockquote>#ge
    " Sarrow: 2010年12月20日 something wrong with here!
    silent %s#</blockquote>\n<blockquote>#<br />\r#ge

    " empty-line => paragrahp
    silent %s#^\s*\([^<].\+\)$#<p>\1</p>#ge
    silent %s#</p>\n<p>#<br />\r#ge

    silent %s#</a>\zs\n\ze<a#<br />\r#ge
    let @".="<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n"
    let @".="<html xmlns=\"http://www.w3.org/1999/xhtml\">\n"
    let @".="<head>\n"
    let @".="<title>"._title_."</title>\n"
    let @".="<meta name='Generator' content='Vim 7.3 (Vi IMproved editor; http://www.vim.org/)' />\n"
    let @".="<meta http-equiv=\"Content-Type\" content=\"text/html; charset="._file_encoding_."\" />\n"
    let @".="<meta name='Author' content=' ' />\n"
    let @".="<meta name='Copyright' content='Copyright (C) "._time_." ' />\n"
    let @".="<link rev='made' href='mailto:"._email_."'/>\n"
    let @".="<style type='text/css'>\n"
    let @".="<!--\n"
    let @".="body { background-color=#FFFFFF; color=#000000; padding-left: 10%; padding-right: 10%; }\n"
    let @".="#menu { position: fixed; top: 20px; right: 600px; margin-right: -500px; }\n"
    let @".="#menu ul { float: right; width: 200px;}\n"
    let @".="h1 { margin-left: -2em; }\n"
    let @".="h2 { margin-left: -1.5em; }\n"
    let @".="h3 { margin-left: -1em; }\n"
    let @".="a:link {color: #0000EE;}\n"
    let @".="a:visited {color: #990066;}\n"
    let @".="a:hover, a:active, a:focus {color: #FF0000;}\n"
    let @".="-->\n"
    let @".="</style>\n"
    let @".="</head>\n"
    let @".="<body>\n"
    " Sarrow: 2010-12-19
    normal ggP
    let @" = "<div id=\"menu\">\n"
    let @".= "<ul class=\"none\">\n"
    for _i_ in s:_ch_name_tbl_
	let @".= "<li>"._i_."</li>\n"
    endfor
    let @".= "</ul>\n"
    let @".= "</div>\n"
    let @".= "</body>\n"
    let @".= "</html>"
    normal Gp
    let @" = _tmp_
    let s:_ch_name_tbl_=[]
endfunction
command! -nargs=? -range=% -complete=file -buffer Text2Html	call <SID>Text2Html(<line1>, <line2>, <q-args>)

function! s:HTML_Make_title() " {{{1
    let _n_dep_ = string(strlen(submatch(1))) 

    if     len(s:_stems_) == _n_dep_ - 1
	let s:_stems_ = add(s:_stems_, 1)
    elseif len(s:_stems_) == _n_dep_
	let s:_stems_[-1] += 1
    elseif len(s:_stems_) > _n_dep_
	let s:_stems_ = s:_stems_[0: (_n_dep_ - 1)]
	let s:_stems_[-1] += 1
    else
	echohl Error
	echomsg 'Wrong Title Levle! expecting level '.(len(s:_stems_) + 1)
	echohl None
    endif
    let _id_ = join(s:_stems_, '_')
    call add(s:_ch_name_tbl_, '<a href="#'._id_.'">'.submatch(2).'</a>')
    return '<h'._n_dep_.' id="'. _id_.'">'.submatch(2).'</h'._n_dep_.'>'
endfunction

let b:current_syntax="text"	"{{{1
