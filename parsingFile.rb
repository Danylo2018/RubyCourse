class ATM
	@@banknotes = Hash.new	 # hash to keep counts of the banknote
	@@accounts = Hash.new		 # hash to keep accounts
	def parseFile(file)
		banknoteStream = false   # show when we get from file count of the banknote
		accountStream = false	 # show when we get from file the accouts
		inOnesAccount = nil		 # keep code of account
		data = file
		puts data
		File.open( data, "r") do |f|
  			f.each_line do |line|
  			# check when we start work with banknotes
    		if (line.include? ("banknotes:"))
    			banknoteStream = true   	
   				# check when we start work with banknotes
    		elsif(line.include? ("accounts:"))
    			accountStream = true
    			banknoteStream = false
   			elsif (banknoteStream)
    			# parsing count of different banknotes 
    			@@banknotes[line.split(':')[0].strip] = line.split(':')[1].strip
    		elsif (accountStream)
    			#parsing data about accounts and create inner hash in hash
    			if(line.length <= 9)
    				@@accounts[line.split(':')[0].strip] = Hash.new
    				inOnesAccount = line.split(':')[0].strip
    			else 
    				@@accounts[inOnesAccount][line.split(':')[0].strip] = [line.split(':')[1].strip] 

    			end
    		end
  		end
		end
	end
	def getBanknotes
		return @@banknotes
	end
	def getAccounts
		return @@accounts
	end
end


authorize = ATM.new  #create new object
authorize.parseFile(ARGV[0])
work = true   # help to keep loop
while (work)
	puts "Please enter your account number:"
	inputAccountCode = STDIN.gets.chomp
	accounts = authorize.getAccounts   #hash tables
	banknotes = authorize.getBanknotes 
	if (accounts[inputAccountCode.to_s])
		#password from file
		pass = accounts[inputAccountCode]["password"].to_s
		pass = pass[3...-3]
		puts "Enter Your Pasword:"
		inputAccountPassword = STDIN.gets.chomp.to_s
		userWork = true  #help continue loop when user stay in account
		while (userWork)
			if(pass == inputAccountPassword)
				puts "\nHello, " + 
				accounts[inputAccountCode]["name"].to_s[3...-3] + "\n"
				puts "Please chose from the following options:\n" +
				"1. Display balance \n2. Withdraw \n3.Log Out\n"
				choose = STDIN.gets.chomp.to_s
				if (choose == "1")
					puts "Your current balance is $" + 
					accounts[inputAccountCode]["balance"].to_s[2...-2]
				elsif(choose == "2")
					workAmount = true #continue loop when user give amounts
					while (workAmount)
						puts "Enter amount you wish to withdraw:"
						amount = STDIN.gets.chomp.to_i
						#chek if amount not bigger then ballance
						if(amount <= Integer(accounts[inputAccountCode]["balance"].to_s[2...-2]))
							cashe = (Integer(banknotes["500"]) * 500 ) +  (Integer(banknotes["200"]) * 200 ) +
								 (Integer(banknotes["100"]) * 100 ) + (Integer(banknotes["50"]) * 50 ) +
								 	 (Integer(banknotes["20"]) * 20 ) + (Integer(banknotes["10"]) * 10 ) +
								 	 	 (Integer(banknotes["5"]) * 5 ) + (Integer(banknotes["2"]) * 2 ) +
								 	 	 	 (Integer(banknotes["1"]) * 1 ) 

							#check if amount not bigger then cashe int ATM
							if(amount <= cashe)
								processCashe =amount
								canGive = true
								#array that containe all possible banknotes
								ar = [500, 200, 100, 50, 20, 10, 5, 2, 1]
								i=0
								#loop go by differrent banknotes
								while (processCashe !=0 and canGive and i<9)
									#loop that go on one banknote
									while(Integer(banknotes[ar[i].to_s]) >0  and processCashe >= ar[i] )
											 processCashe = processCashe - ar[i]
											banknotes[ar[i].to_s] = Integer(banknotes[ar[i].to_s]) -1
									end
									i= i+1
								end
								if(processCashe>0)
									banknotes = authorize.getBanknotes
									puts "ERROR:THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:"
								else 
									 accounts[inputAccountCode]["balance"] =
									(Integer(accounts[inputAccountCode]["balance"].to_s[2...-2]) - amount).to_s.insert(0, "['").insert(-1, "']")
									
									workAmount = false
								end
							else 
								puts "ERROR: The maximum amount available in this ATM is $" +
								cashe.to_s + ". Please enter a different amount:"
							end
						else 
							puts "ERROR: INSUFICIENT FUNDS!!! PLEASE ENTER ANOTHER AMOUNT:"
						end
					end	
				else 
					puts accounts[inputAccountCode]["name"].to_s[3...-3]+ 
					"Thank You for using our ATM. Goog bye!\n"
					userWork = false
				end
			else
				puts "Error. You made mistake in your password\n"
			end
		end	
	else
		puts "We havn't such account!U can try again. Choose:"
		puts "1. Try again"
		puts "2. Exit\n"
		input = STDIN.gets.chomp
		if(input == "1" )
			work = true
		else
			puts "Bye!"
			work = false
		end
	end
end
