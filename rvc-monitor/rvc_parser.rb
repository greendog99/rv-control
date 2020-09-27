require 'yaml'
require_relative 'bitmath'

class RVCParser
  @@rvc_spec_location = 'rvc-spec.yaml'

  def initialize()
    yaml_data = File.read(@@rvc_spec_location)

    # Some keys in the yaml file are bitfields (e.g. 001) and need to
    # be parsed as strings instead of integers, to avoid losing the
    # leading zeros. Add quotes around all keys that begin with a digit.
    yaml_data = yaml_data.gsub(/(\s)(\d+):/, '\1"\2":')
    @rvc_spec = YAML.load(yaml_data)
  end

  public

  def api_version
    @rvc_spec['API_VERSION']
  end

  def decode(dgn, data)
    result = {}
    result['dgn'] = result['name'] = dgn
    result['data'] = data

    # If no decoder is found, abort now.
    return result unless decoder = @rvc_spec[dgn]

    result['name'] = decoder['name']
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
      unit = sanitize_string param['unit']

      value = hex_byterange(data, byte_range)
      if bit_range
        value = value.bitrange(bit_range, bytes: 1)
        value = value.padded_binary(bits: bit_range.size) if type.include?('bit')
      end

      value = unit_conversion(value, unit, type)
      result[name] = value

      # Special case: also store temperatures in farenheit.
      if unit == 'deg_c'
        result["#{name}_f"] = value * 9 / 5 + 32
      end

      if values = param['values']
        definition = values[value.to_s] || 'undefined'
        result["#{name}_definition"] = definition
      end

    end

    return result
  end

  protected

  # Convert a DGN's name to something more computer-friendly.
  #
  #   "Manufacturer Code (LSB) in/out" => "manufacturer_code_lsb_in_out"
  def sanitize_string(str)
    str ? str.downcase.tr(' /', '_').tr('()', '') : nil
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

  # Convert raw value to RVC percentage.
  #   min = 0 / max = 125 / precision = 0.5% / 255 = data not available
  def convert_pct(value, type)
    value <= 252 ? value / 2.0 : value
  end

  # Convert raw value to degrees celcius.
  #   uint8:  min: -40 / max: 210 / precision: 1 ºC
  #   uint16: min: -273 / max: 1735 / precision: 0.03125 ºC
  def convert_deg_c(value, type)
    case type
    when 'uint8'
      return value <= 252 ? value - 40 : value
    when 'uint16'
      return value <= 65532 ? value * 0.03125 - 273 : value
    end
  end

  # Convert raw value to volts.
  #   uint8:  min: 0 / max: 250 / precision: 1 V
  #   uint16: min: 0 / max: 3212.5 / precision: 0.05 V
  def convert_v(value, type)
    case type
    when 'uint8'
      return value
    when 'uint16'
      return value <= 65532 ? value * 0.05 : value
    end
  end

  # Convert raw value to amps.
  #   uint8:  min: 0 / max: 250 / precision: 1 A
  #   uint16: min: -1600 / max: 1612.5 / precision: 0.05 A / 0A = 0x7D00
  def convert_a(value, type)
    case type
    when 'uint8'
      return value
    when 'uint16'
      return value <= 65532 ? value * 0.05 - 1600 : value
    end
  end

  # Convert raw value to hertz.
  #   uint8:  min: 0 / max: 250 / precision: 1 Hz
  #   uint16: min: 0 / max: 500 / precision: 1/128 Hz
  def convert_hz(value, type)
    case type
    when 'uint8'
      return value
    when 'uint16'
      return value <= 64000 ? value / 128.0 : value
    end
  end

  def convert_bitmap(value, type)
    value.padded_binary
  end

  # Convert a raw value to a final value based on the requested unit (e.g. volts, amps,
  # percent) and data type (e.g. uint16). See RVC Specification table 5.3 for details.
  def unit_conversion(value, unit, type)
    if ['pct', 'deg_c', 'v', 'a', 'hz', 'bitmap'].include?(unit)
      value = self.method("convert_" + unit).call(value, type)
    end
    value
  end

end

