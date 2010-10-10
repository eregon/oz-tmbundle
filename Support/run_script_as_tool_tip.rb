require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"

TextMate.save_current_document('oz')

require File.expand_path('../oz_compiler', __FILE__)

if result = oz_compile(ENV['TM_FILEPATH']) { |executable|
    system(executable)
  }
  $stderr.puts result
end
