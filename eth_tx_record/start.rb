require 'json'
require "open-uri"
require 'find'
require "redis"
$redis = Redis.new(:host => 'localhost', :port => 6379)

class ScanBlockChain

	def initialize
    
  end

	def block_number
		post_rpc("eth_blockNumber",[])['result'].to_i(16)
	end

	def balance_of(eth_address)
		post_rpc("eth_getBalance",[eth_address,'latest'])['result'].to_i(16)
	end

	def get_block_tx(block_number)
		post_rpc("eth_getBlockByNumber",[block_number,true])
	end

	def get_tx_body(txhash)
		post_rpc("eth_getTransactionReceipt",[txhash])
	end

	def scan_file(contract_address,tx_h,address_1,address_2,value,tp,time)
		if !File.directory?("./#{contract_address}/#{address_1[0..4]}")
      `mkdir "./#{contract_address}/#{address_1[0..4]}"`
      `chmod 777 "./#{contract_address}/#{address_1[0..4]}"`
      file = File.new("./#{contract_address}/#{address_1[0..4]}/#{address_1}", "a+")
      #File.open(file, 'a+'){|f| f << ""}
    end
    file_text = File.read("./#{contract_address}/#{address_1[0..4]}/#{address_1}")
    if !(file_text.include? tx_h)
			file = File.new("./#{contract_address}/#{address_1[0..4]}/#{address_1}", "a+")
			File.open(file, 'a+'){|f| f << "#{tx_h},#{tp},#{address_2},#{value},#{time}\n"}
			#puts "transactionHash:#{tx_json['result']['transactionHash']}~~~~~~from:0x#{tx_body['topics'][1].to_i(16).to_s(16).rjust(40, '0')}~~~~to:0x#{tx_body['topics'][2].to_i(16).to_s(16).rjust(40, '0')}~~~~#{tx_body['data'].to_i(16)/1e18} GENE"
		end
	end
	private
		def set_address_file(tx_body,st)
			
		end
		def post_rpc(method_name,params_arr)
			eth_rpc_url = "http://192.168.1.11:8545"
			#eth_rpc_url = "https://mainnet.infura.io"
			result = `curl -X POST -H 'content-type: application/json' --data '{"jsonrpc":"2.0","method":"#{method_name}","params":#{params_arr},"id":84}' "#{eth_rpc_url}"`
	    JSON.parse result
	  end
end

sbc = ScanBlockChain.new
contract_list = ['0x884181554dfa9e578d36379919c05c25dc4a15bb']
#$redis.set('scan_eth_block_number',6474812)
#$redis.set('scan_eth_block_number',6543052)

puts $redis.get('scan_eth_block_number')

#puts sbc.get_block_tx("0x"+(5506194).to_s(16))
while true
	#begin
		now_block_number = sbc.block_number.to_i
		$redis.set('scan_eth_block_number',now_block_number) if !$redis.get('scan_eth_block_number')
		old_block_number = $redis.get('scan_eth_block_number').to_i 
		address_list = File.read("./address_list")
		while old_block_number < now_block_number && true
			puts old_block_number
			old_block_number = old_block_number + 1
			block_tx_json = sbc.get_block_tx("0x"+(old_block_number).to_s(16))
			tx_list = block_tx_json['result']['transactions']
			time = block_tx_json['result']['timestamp'].to_i(16)
			tx_list.each do |tx|
				scan_st = false
				if tx['value'] #&& tx['value'].to_i(16) > 0 
					if tx['from'] && (address_list.include? tx['from'])
						sbc.scan_file("eth",tx['hash'],tx['from'],tx['to'],tx['value'].to_i(16)/1e18,"send",time)
					end
					if tx['to'] && (address_list.include? tx['to'])
						sbc.scan_file("eth",tx['hash'],tx['to'],tx['from'],tx['value'].to_i(16)/1e18,"receive",time)
					end
				end
				contract_list.each do |contract_address|
					if (tx['input'].include? contract_address.gsub("0x","")) || tx['to'] == contract_address
						scan_st = true
					end
				end


				if scan_st
					tx_json = sbc.get_tx_body(tx['hash'])
					tx_json['result']['logs'].each do |tx_body|
						if tx_body['topics'].size > 2 && (contract_list.include? tx_body['address'])
							address_from = "0x#{tx_body['topics'][1].to_i(16).to_s(16).rjust(40, '0')}"
							address_to = "0x#{tx_body['topics'][2].to_i(16).to_s(16).rjust(40, '0')}"
							sbc.scan_file(tx_body['address'],tx_json['result']['transactionHash'],address_to,address_from,tx_body['data'].to_i(16)/1e18,"receive",time) if (address_list.include? address_to)
							sbc.scan_file(tx_body['address'],tx_json['result']['transactionHash'],address_from,address_to,tx_body['data'].to_i(16)/1e18,"send",time) if (address_list.include? address_from)
						end
					end
				end
			end
		end
		$redis.set('scan_eth_block_number',now_block_number)
	#rescue
	#end
	sleep 5
end
