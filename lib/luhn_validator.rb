# LuhnValidator Module
module LuhnValidator
  # Validates credit card number using Luhn Algorithm
  # arguments: none
  # assumes: a local String called 'number' exists
  # returns: true/false whether last digit is correct
  def validate_checksum
    nums_a = number.to_s.chars.map(&:to_i)

    # TODO: use the integers in nums_a to validate its last check digit

    # Reversing the array and multiplying the value in every other index by 2
    n_arr = nums_a.reverse.map.with_index { |n, i| i.even? ? n : n * 2 }

    # adding up the digits in any number that has more than one digit
    n_arr.map! { |n| n > 9 ? n.to_s.chars.map(&:to_i).reduce(:+) : n }
    # adding up all numbers
    check_digit = ((n_arr[1..n_arr.length - 1].reduce(:+)) * 9) % 10

    # implicit return to check whether check_digit is correct
    check_digit == nums_a.last
  end
end
