module LuhnValidator
  # Validates credit card number using Luhn Algorithm
  # arguments: none
  # assumes: a local String called 'number' exists
  # returns: true/false whether last digit is correct
  def my_inject(a, b)
    a.each_index.inject(0) do |sum, index|
      c = b * a[index]
      if index.even?
        sum + a[index]
      elsif c >= 10
        sum + my_inject((c.to_s.chars.map(&:to_i)), 1)
      else
        sum + c
      end
    end
  end

  def validate_checksum
    nums_a = number.to_s.chars.map(&:to_i)

    nums_a.reverse!
    checksum = my_inject(nums_a, 2)
    checksum % 10 == 0
  end
end
