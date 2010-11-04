def oz_compile(file)
  file = File.expand_path file
  code = File.read file

  unless code =~ /^\s*functor\b/ # if we alredy have the functor, expect it to be right
    imports = %w[Application System]

    code_without_comments = code.lines.reject { |line| line =~ /^\s*%/ }.join

    # Try to get modules needed
    imports |= code_without_comments.scan(/\b[A-Z][a-z]+(?=\.[a-z]\w*)/).uniq

    # Remove builtin modules
    imports -= %w[List Tuple]

    # Remove graphical dependencies
    code.gsub! /\{(Browse|Show) /, '{System.show '

    # warn if no declare
    if code !~ /\bdeclare\b/ and (code =~ /\bfun\b/ or code =~ /\b=\b/)
      $stderr.puts "Warning: no declare found, it won't work with normal emulation"
    end

    # define already "declare"
    code.gsub! /\bdeclare\b/, ''

    # do not exit if we have a browser
    code << "\n{Application.exit 0}" unless imports.include? 'Browser' or code.include? '{Application.exit '

    code = <<CODE
functor
import
#{imports.map { |import| "  #{import}" } * "\n"}
define
#{code}
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

  executable = nil if !errors.empty? and !errors.include?('-------------------- accepted')

  return errors, executable
end
