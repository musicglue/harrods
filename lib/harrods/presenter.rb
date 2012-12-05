module Harrods
  module Presenter
  
    K = 2.0**10
    M = 2.0**20
    G = 2.0**30
    T = 2.0**40
    def present_storage_size( bytes, max_digits=3 )
      value, suffix, precision = case bytes
        when 0...K
          [ bytes, 'B', 0 ]
        else
          value, suffix = case bytes
            when K...M then [ bytes / K, 'kB' ]
            when M...G then [ bytes / M, 'MB' ]
            when G...T then [ bytes / G, 'GB' ]
            else            [ bytes / T, 'TB' ]
          end
          used_digits = case value
            when   0...10   then 1
            when  10...100  then 2
            when 100...1000 then 3
          end
          leftover_digits = max_digits - used_digits
          [ value, suffix, leftover_digits > 0 ? leftover_digits : 0 ]
      end
      "%.#{precision}f#{suffix}" % value
    end
    
    def present_with_commas(num)
       str =  num.to_s
       a = []
       str.split(//).reverse.each_slice(3) { |slice| a << slice }
       new_a = []
       a.each do |item|
         new_a << item
         new_a << [","]
       end
       new_a.delete_at(new_a.length - 1)
       new_a.flatten.reverse.join
    end
  
  end
end