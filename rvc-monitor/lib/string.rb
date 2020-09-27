class String

  # Convert a string to something easier to use as a JSON parameter by
  # converting spaces and slashes to underscores, and removing braces.
  #   "Manufacturer Code (LSB) in/out" => "manufacturer_code_lsb_in_out"
  def rvc_parameter
    self ? self.downcase.tr(' /', '_').tr('(){}[]', '') : nil
  end

  # Reverse a hex string's endianness:
  #   "ABCD" => "CDAB"
  def reverse_endianness
    self.scan(/../).reverse.join('')
  end

  # Convert a string representation of a number or numeric range into a
  # Ruby Range object:
  #   "2"   => 2..2
  #   "2-4" => 2..4
  def to_range
    return nil if self.empty?

    first, last = self.split(/-/).map { |val| val.to_i }
    last ||= first
    first..last
  end

end

