require 'v8'

def cryptojs_pathname
  PROJECT_ROOT.join('bower_components', 'crypto-js', 'rollups', 'aes.js')
end

def v8_with_cryptojs
  js = V8::Context.new
  js.load(cryptojs_pathname.to_s)
  js
end
