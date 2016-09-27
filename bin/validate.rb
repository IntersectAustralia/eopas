#! /usr/bin/env ruby

# call this as:
# rails runner bin/validate.rb features/test_data/toolbox2.xml Toolbox

# Running on the server, might need to set the env
# Watch where the e flag goes cause this script wants ARG 0 to be the file
# rails runner ~/eopas/current/bin/validate.rb ~/eopas/current/features/test_data/daisy.eaf Elan -e production

require 'transcription'

t = Transcription.new(:data => File.read(ARGV[0]), :format => ARGV[1])
t.validate
if t.valid?
  puts "valid file"
else
  puts t.errors
end