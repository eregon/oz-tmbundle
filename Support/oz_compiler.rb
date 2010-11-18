def oz_compile(file)
  file = File.expand_path file
  code = File.read file
  errors = ''

  unless code =~ /^\s*functor\b/ # if we alredy have the functor, expect it to be right
    all_modules = Dir['/Applications/Mozart.app/Contents/Resources/cache/x-oz/system/*.ozf'].map { |f| File.basename(f, '.ozf') }

    code_without_comments = code.lines.reject { |line| line =~ /^\s*%/ }.join

    # Try to get modules needed
    imports = code_without_comments.scan(/\b[A-Z][A-Za-z]+(?=\.[a-z]\w*)/).uniq

    # Remove builtin modules
    imports -= %w[Array List Tuple Record Dictionary]

    (imports-all_modules).each { |unknown| errors << "Unknown module: #{unknown}\n" }

    imports &= all_modules
    imports |= %w[Application System]

    # Remove graphical dependencies
    code.gsub! /\{(Browse|Show) /, '{System.show '

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
  compilation = ''
  tmpfile = "#{executable}.oz.tmp"
  File.open(tmpfile, "w+") { |fh| fh.write code }

  IO.popen(["ozc", "-x", "-o#{executable}", tmpfile, :err => [:child, :out]]) do |io|
    begin
      compilation = io.read
    ensure
      File.unlink tmpfile
    end
  end

  executable = nil if !compilation.empty? and !compilation.include?('-------------------- accepted')

  return errors+compilation, executable
end
