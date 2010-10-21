def oz_compile(file)
  file = File.expand_path file
  code = File.read file

  unless code =~ /^\s*functor\b/ # if we alredy have the functor, expect it to be right
    imports = %w[Application System]

    # Try to get modules needed
    imports |= code.scan(/\b[A-Z]\w+(?=\.[a-z]\w*)/).uniq

    # Remove builtin modules
    imports -= %w[List Tuple]

    # Remove graphical dependencies
    code.gsub! /\{(Browse|Show) /, '{System.show '

    # define already "declare"
    code.gsub! /\bdeclare\b/, ''

    code = <<CODE
functor
import
#{imports.map { |import| "  #{import}" } * "\n"}
define
#{code}
{Application.exit 0}
end
CODE
  end

  executable = File.join File.dirname(file), File.basename(file, '.oz')
  errors = ''
  tmpfile = "#{executable}.oz.tmp"
  File.open(tmpfile, "w+") { |fh| fh.write code }

  IO.popen(["ozc", "-x", "-o#{executable}", tmpfile, :err => [:child, :out]]) do |io|
    begin
      errors = io.read
    ensure
      File.unlink tmpfile
    end
  end

  return errors, executable
end
