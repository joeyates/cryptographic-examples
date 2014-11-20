def part_after_equals(text)
  text.scan(/=(.*)/)[0][0]
end

def hex_to_raw(text)
  [text].pack('H*')
end
