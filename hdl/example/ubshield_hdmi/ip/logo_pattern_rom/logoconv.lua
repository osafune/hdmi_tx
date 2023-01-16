infile = io.open("DVD-logo_256x148_1bit.xpm","r")
outfile = io.open("dvdlogo.mif","wb")

-- 入力ファイル先頭の5行を読み飛ばす
for i=1,5 do infile:read() end

-- 出力ファイルヘッダ作成
outfile:write("WIDTH=1;\n","DEPTH=37888;\n","ADDRESS_RADIX=UNS;\n","DATA_RADIX=UNS;\n")

-- 画像データを変換
outfile:write("CONTENT BEGIN\n")
for y=1,148 do
	s = infile:read()
	str = tostring((y-1)*256).." :"
	for x=1,256 do
		if s:sub(x+1,x+1) == "." then
			str = str .. " 0"
		else
			str = str .. " 1"
		end
	end
	outfile:write(str,";\n")
end
outfile:write("END;\n")

infile:close()
outfile:close()
