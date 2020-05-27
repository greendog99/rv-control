require 'yaml'
require './bitmath'

class RVCParser

  @@rvc_spec_location = 'rvc-spec.yml'

  def initialize()
    @rvc_spec = YAML.load(File.read(@@rvc_spec_location))
  end


  public


  def api_version
    @rvc_spec['API_VERSION']
  end


  def decode(dgn, data)
    result = {}
    result[:dgn] = result[:name] = dgn
    result[:data] = data

    # If no decoder is found, abort now.
    return result unless decoder = @rvc_spec[dgn]

    result[:name] = decoder["name"]
    params = []

    # If this decoder has an alias, load the alias's parameters first. Then load
    # the normal parameters, which will override any parameters from the alias.
    params += @rvc_spec[decoder['alias']]['parameters'] if decoder['alias']
    params += decoder['parameters'] if decoder['parameters']

    # Loop through each parameter and decode it.
    params.each do |param|
      byte_range = str_to_range param['byte']
      bit_range  = str_to_range param['bit']
      name = sanitize_string param['name']
      type = param['type'] || 'uint'
      unit = param['unit']
      values = param['values']

      value = hex_byterange(data, byte_range)
      if bit_range
        value = value.bitrange(bit_range, bytes: 1)
        value = value.padded_binary(bits: bit_range.size) if type.include?('bit')
      end

      # Convert units (%, V, A, ºC)
      #value = unit_value(value, unit, type) if unit

      result[name] = value
    end



    return result
  end


  private

  # Convert a DGN's name to something more computer-friendly.
  #
  #   "Manufacturer Code (LSB) in/out" => "manufacturer_code_lsb_in_out"
  def sanitize_string(str)
    str.downcase.tr(' /', '_').tr('()', '')
  end


  # Reverse a hex string's endianness.
  #
  #   "ABCD" => "CDAB"
  def flip_hex_bytes(hex)
    hex.scan(/../).reverse.join('')
  end


  # Convert a string representation of a number or numeric range into a
  # Ruby Range object:
  #
  #   "2"   => 2..2
  #   "2-4" => 2..4
  def str_to_range(str)
    return nil if !str

    str = str.to_s    # Just in case a single integer is passed in
    first, last = str.split(/-/).map { |val| val.to_i }
    last ||= first
    first..last
  end


  # Take a hex string (e.g. "020064C524C52400") and a byte range (e.g. 2..4 and
  # return the decimal value for those bytes. Per RV-C spec, "data consisting of
  # two or more bytes shall be transmitted least significant byte first." Thus,
  # the byte order must be swapped. Also, a simple string range won't suffice
  # since each byte occupies two characters in the string. The range needs to be
  # doubled in scope (bytes 0-1 are characters 0-3 in the hex string).
  def hex_byterange(data, range)
    byte_range = (range.begin * 2)..(range.end * 2 + 1)
    flip_hex_bytes(data[byte_range]).hex
  end


  def unit_value(value, unit, type)
    value
  end

end

