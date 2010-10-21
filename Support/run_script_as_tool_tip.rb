require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"

TextMate.save_current_document('oz')

require File.expand_path('../oz_compiler', __FILE__)

errors, executable = oz_compile(ENV['TM_FILEPATH'])

if errors.empty?
  system(executable)
else
  $stderr.puts errors
  system(executable)
end
