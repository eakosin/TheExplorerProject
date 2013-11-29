function build2DArray(m, n, val):
	val = val or "0"
	local newTable = {}
	for x=1,m do
		for y=1,n do
			newTable[x][y] = val
		end
	end
end

function table:print2DArray(m, n, val):
	for x=1,m do
		for y=1,n do
			io.write(self[x][y])
		end
		io.write("\n")
	end
end