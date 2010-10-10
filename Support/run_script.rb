require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"

TextMate.save_current_document('oz')

require 'tempfile'
file = File.expand_path ENV['TM_FILEPATH']
code = File.read file

# Remove graphical dependencies
code.gsub! /\{(Browse|Show) /, '{System.show '

# define already "declare"
code.gsub! /\bdeclare\b/, ''

unless code =~ /^\s*functor\b/ # if we alredy have the functor, expect it to be right
  code = <<CODE
functor
import
  Application
  System
define
#{code}
{Application.exit 0}
end
CODE
end

executable = File.join File.dirname(file), File.basename(file, '.oz')

Tempfile.open('ozcx') { |tmpfile|
  tmpfile.write code
  tmpfile.close
  unless system("ozc", "-x", "-o#{executable}", tmpfile.path)
    puts "BEGIN"
    puts code
    puts "END"
  end
  tmpfile.unlink
}

# puts executable
oz_version = `ozc -v 2>&1`.split("\n").first
TextMate::Executor.run(executable, :use_hashbang => false, :version_replace => oz_version)
