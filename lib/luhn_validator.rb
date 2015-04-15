# Luhn Validator
module LuhnValidator
  # Validates credit card number using Luhn Algorithm
  # arguments: none
  # assumes: a local String called 'number' exists
  # returns: true/false whether last digit is correct

  def validate_checksum
    nums_a = number.to_s.chars.map(&:to_i)
    nums_a.reverse!
    checksum = 0
    nums_a.each_with_index do |x, idx|
      2 * x >= 10 ? b = 2 * x - 9 : b = 2 * x
      idx.odd? ? checksum += b : checksum += x
    end
    checksum % 10 == 0
  end
end
