module IntegerBitMath

  # Convert an integer to its corresponding binary representation. The number of
  # bits in the integer should be specified (default 8) in order to left-pad the
  # string with zeroes.
  #
  #   17     => "00010001"
  #   257    => "100000001"
  #   257, 2 => "0000000100000001"
  def padded_binary(bits: 8)
    self.to_s(2).rjust(bits, '0')
  end

  # Extract a range of bits from an integer and return the resulting integer
  # value. When converted to a string, bit 0 is the last bit in the string, so
  # the range must be modified to compensate (a bit range of 0..1 is characters
  # 6..7 in an 8-bit string). The number of bytes in the integer should be
  # specified (default 1) in order to left-pad the string with zeroes.
  #
  #   E.g.: 121 in binary is "01111001" (with leading zero)
  #   121, 0..1 => 1 ("01")
  #   121, 5..7 => 3 ("011")
  def bitrange(range, bytes: 1)
    new_range = (bytes * 8 - range.end - 1)..(bytes * 8 - range.begin - 1)
    self.padded_binary(bits: bytes * 8)[new_range].to_i(2)
  end

end


class Integer
  include IntegerBitMath
end
