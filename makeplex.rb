#! /usr/bin/env ruby

require 'digest/md5'

class Makeplex

	def initialize(s)
		@odai = s

		@hai_num = [].fill(0, 1, 9)
		s.unpack('aaaaaaaaaaaaa').each { |c|
			@hai_num[c.to_i] += 1
		}

		@result = Hash.new
	end

	def resolv
		# 頭なし (つまり頭 = 待ち、メンツを4つ作ろう)
		(1..9).each { |i|
			next if @hai_num[i] < 1

			resolv_rec(@hai_num.clone, 4, [i], "[%s]", [])
			resolv_niconico(@hai_num.clone, 6, [i], "[%s]", [])
		}

		# 頭あり (つまり、メンツを三つと、シュンツorコーツでの待ちを1つ作ろう)
		(1..9).each { |i|
			next if @hai_num[i] < 2

			resolv_mati(@hai_num.clone, 4, [i, i], "(%s)", [])
		}

		@result.values
	end

	def resolv_niconico(hai_num, nums, used, fmt, result_pair)
		used_str = ''
		used.each { |c|
			raise "error" if hai_num[c] <= 0

			hai_num[c] -= 1
			used_str += c.to_s
		}
		result_pair.push sprintf(fmt, used_str)

		if nums == 0
			key = Digest::MD5.digest(result_pair.sort.to_s)
			@result[key] = result_pair.sort.to_s
			return
		end

		# ニコニコ判定
		(1..9).each { |i|
			# (11)(22)(33)(44)(55)(66)(77)(88)(99)
			resolv_niconico(hai_num.clone,  nums - 1, [i, i], "(%s)", result_pair.clone) if hai_num[i] >= 2
		}
	end


	def resolv_mati(hai_num, nums, used, fmt, result_pair)
		used_str = ''
		used.each { |c|
			raise "error" if hai_num[c] <= 0

			hai_num[c] -= 1
			used_str += c.to_s
		}
		result_pair.push sprintf(fmt, used_str)

		# シュンツorコーツでの待ちをまず一つ作って、その後は resolv_rec に任せる
		(1..9).each { |i|
			# [11][22][33][44][55][66][77][88][99]
			resolv_rec(hai_num.clone,  nums - 1, [i, i], "[%s]", result_pair.clone) if hai_num[i] >= 2

			# [12][23][34][45][56][67][78][89]
			resolv_rec(hai_num.clone,  nums - 1, [i, i + 1], "[%s]", result_pair.clone) if i <= 8 && hai_num[i] >= 1 && hai_num[i + 1] >= 1

			# [13][24][35][46][57][68][79]
			resolv_rec(hai_num.clone,  nums - 1, [i, i + 2], "[%s]", result_pair.clone) if i <= 7 && hai_num[i] >= 1 && hai_num[i + 2] >= 1
		}
	end



	def resolv_rec(hai_num, nums, used, fmt, result_pair)
		used_str = ''
		used.each { |c|
			raise "error" if hai_num[c] <= 0

			hai_num[c] -= 1
			used_str += c.to_s
		}
		result_pair.push sprintf(fmt, used_str)

#p nums
#p result_pair.sort.to_s
#p hai_num
		if nums == 0
			key = Digest::MD5.digest(result_pair.sort.to_s)
			@result[key] = result_pair.sort.to_s
			return
		end


		(1..9).each { |i|
			#こーつ
			resolv_rec(hai_num.clone,  nums - 1, [i, i, i], "(%s)", result_pair.clone) if hai_num[i] >= 3

			#しゅんつ
			resolv_rec(hai_num.clone,  nums - 1, [i, i + 1, i + 2], "(%s)", result_pair.clone) if i <= 7 && hai_num[i] >= 1 && hai_num[i + 1] >= 1 && hai_num[i + 2] >= 1
		}

	end

	def print_anser
		print "#{@odai} は #{@result.length} 個\n";

		@result.each {|key, val|
			p val
		}
	end
end

makeplex = Makeplex.new("1112345678999")
#makeplex = Makeplex.new("1122334455669")
result = makeplex.resolv
makeplex.print_anser

# makeplex.resolv で、回答が配列として帰ってくる

