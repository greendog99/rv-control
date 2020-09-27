# Additional methods added to Ruby's Integer class.
module IntegerBitMath

  # Convert an integer to its corresponding binary string representation. The
  # number of bits in the integer may be specified (default: 8) in order to
  # left-pad the string with zeros.
  #
  #   17.padded_binary      => "00010001"
  #   257.padded_binary     => "100000001"
  #   257.padded_binary(16) => "0000000100000001"
  def padded_binary(bits: 8)
    self.to_s(2).rjust(bits, '0')
  end

  # Extract a range of bits from an integer and return the resulting integer
  # value. When converted to a string, bit 0 is the last bit in the string, so
  # the range must be modified to compensate (a bit range of 0..1 is characters
  # 6..7 in an 8-bit string). The number of bytes in the integer may be
  # specified (default: 1) in order to left-pad the string with zeros.
  #
  # For example, 121 in binary is "01111001" (with a leading zero):
  #   121.bitrange(0..4) => 1 ("1001")  # The last four characters of the string
  #   121.bitrange(5..7) => 3 ("011")   # The first three characters of the string
  def bitrange(range, bytes: 1)
    new_range = (bytes * 8 - range.end - 1)..(bytes * 8 - range.begin - 1)
    self.padded_binary(bits: bytes * 8)[new_range].to_i(2)
  end

end


class Integer
  include IntegerBitMath
end
