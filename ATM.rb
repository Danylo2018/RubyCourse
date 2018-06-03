class FileWork

	def initialize(data)
		@banknotes = Hash.new
		@accounts = Hash.new
		@accountsClasses = Hash.new
		@data = data
		self.parsingFile()
	end

	def parsingFile()
		File.open( @data, "r") do |filePointer|
			filePointer.each_line do |line|
				if(line.include? "banknotes:")
					filePointer = self.banknotesParsing(filePointer)
				end
			end
		end
	end

	def banknotesParsing(filePointer)
		filePointer.each_line do |line|
			if(line.include? "accounts:")
				self.accountsParsing(filePointer)
			else
				self.addBanknote(line.split(':')[0].strip, line.split(':')[1].strip)
			end
		end
		return filePointer
	end

	def accountsParsing(filePointer)
		filePointer.each_line do |line|
			filePointer = self.addAccount(line.split(':')[0].strip, filePointer)
		end
		return filePointer
	end

	def addBanknote(banknoteValue, number)
		@banknotes[banknoteValue] = number
	end

	def addAccount(account, filePointer)
		@accounts[account.to_s] = Hash.new
		filePointer.each_line do |line|
			if((line.split(':')[0].strip).is_i?)
				@accountsClasses[account] = Client.new(@accounts[account]["name"].to_s[3...-3], @accounts[account]["password"].to_s[3...-3], Integer(@accounts[account]["balance"].to_s[2...-2])) 
				filePointer = self.addAccount(line.split(':')[0].strip, filePointer)
			else
				@accounts[account][line.split(':')[0].strip] = [line.split(':')[1].strip] 
			end
		end
		@accountsClasses[account] = Client.new(@accounts[account]["name"].to_s[3...-3], @accounts[account]["password"].to_s[3...-3], Integer(@accounts[account]["balance"].to_s[2...-2])) 
		return filePointer
	end

	def getBanknotes
		return @banknotes
	end

	def getAccounts
		return @accounts
	end

	def getAccountsClasses
		return @accountsClasses
	end

end 

class String
    def is_i?
       /\A[-+]?\d+\z/ === self
    end
end

class Client

	def initialize(name, password, balance)
		@name = name
		@password = password
		@balance = balance
	end

	def getBalance
		return @balance
	end

	def getName
		return @name
	end

	def getPassword
		return @password
	end

	def changeBalance(balance)
		@balance = balance
	end
end
class ATM 

	@@activeClient = nil

	def initialize
		@authorize = FileWork.new(ARGV[0])
		self.countCash
	end

	def authorizing
		puts "Please enter Your account number:"
		code = (Integer(STDIN.gets)).to_s
		if code == "0"
			puts "Good Bye"
			exit
		elsif ((@authorize.getAccountsClasses[code]) != nil)
			puts "Enter your password:"
			if(@authorize.getAccountsClasses[code].getPassword == STDIN.gets.chomp.to_s)
				@@activeClient = @authorize.getAccountsClasses[code]
				self.clientOptions
			else
				self.authorizing
			end
		else
			puts "ERROR! You make mistake in account number!"
			self.authorizing
		end
	rescue ArgumentError
		puts "ERROR! You make mistake in account number!"
		self.authorizing
	
	end

	def clientOptions
		puts "Please chose from the following options:\n" +
			"1. Display balance \n2. Withdraw \n3.Log Out\n"
		case STDIN.gets.chomp
		when "1" 
			self.displayBalance
		when "2"
			self.withdraw
		when "3"
			self.logOut
		else
			puts "ERROR"
			self.clientOptions
		end 
	end

	def displayBalance
		puts @@activeClient.getBalance
		self.clientOptions
	end

	def withdraw
		puts "Enter amount you wish to withdraw:"
		@amount = Integer(STDIN.gets)
		self.checkBalance
		self.clientOptions 
	rescue ArgumentError
		puts "ERROR"
		self.withdraw
	end

	def checkBalance
		if(@amount == 0)
			self.clientOptions
		elsif(@amount < @@activeClient.getBalance)
			self.checkCash
		else
			puts "ERROR: INSUFICIENT FUNDS!!! PLEASE ENTER ANOTHER AMOUNT:"
			self.withdraw
		end
	end

	def checkCash
		if(@amount > @cash)
			puts "ERROR: The maximum amount available in this ATM is $" +
			@cash.to_s + ". Please enter a different amount:" 
			self.withdraw
		else
			self.checkBanknotes
		end
	end

	def checkBanknotes
		ar = [500, 200, 100, 50, 20, 10, 5, 2, 1]
		processCash = @amount
		i=0
		#loop go by differrent banknotes
		while (processCash > 0 and i < 9)
			#loop that go on one banknote
			while(Integer(@banknotes[ar[i].to_s]) > 0  and processCash >= ar[i] )
				processCash = processCash - ar[i]
				@banknotes[ar[i].to_s] = Integer(@banknotes[ar[i].to_s]) - 1
			end
			i = i + 1
		end
		if(processCash != 0) 
			puts @cash 
			puts processCash
			puts @amount
			puts "ERROR:THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT AMOUNT:"
			self.withdraw
		else
			@cash -= @amount
			@@activeClient.changeBalance(@@activeClient.getBalance - @amount)
			self.clientOptions
		end
	end		

	def logOut
		@@activeClient = nil
		self.authorizing
	end

	def countCash
		@banknotes = @authorize.getBanknotes
		@cash = (Integer(@banknotes["500"]) * 500) +(Integer(@banknotes["200"]) * 200) + 
		(Integer(@banknotes["100"]) * 100) + (Integer(@banknotes["50"]) * 50) + 
		(Integer(@banknotes["20"]) * 20) + (Integer(@banknotes["10"]) * 10) +
		(Integer(@banknotes["5"]) * 5) + (Integer(@banknotes["2"]) * 2) + 
		(Integer(@banknotes["1"]) * 1);
	end

end

ATM.new().authorizing
