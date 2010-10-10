def oz_compile(file)
  file = File.expand_path file
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
  result = nil
  tmpfile = "#{executable}.oz.tmp"
  File.open(tmpfile, "w+") { |fh| fh.write code }

  IO.popen(["ozc", "-x", "-o#{executable}", tmpfile, :err => [:child, :out]]) do |io|
    begin
      result = io.read
    ensure
      File.unlink tmpfile
    end
  end

  if result.empty?
    yield(executable)
    nil
  else
    result
  end
end
