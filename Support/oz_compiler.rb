INSERT = /^\\insert '(.+)'$/

def oz_compile(file, options = [])
  file = File.expand_path file
  code = File.read file
  errors = ''
  ignore = %w[Path]

  # \insert 'code.oz'
  while code =~ INSERT
    code.gsub!(INSERT) { File.read(File.expand_path("../#{$1}", file)) }
  end

  unless code =~ /^\s*functor\b/ # if we already have the functor, expect it to be right
    all_modules = Dir['/Applications/Mozart.app/Contents/Resources/cache/x-oz/system/*.ozf'].map { |f| File.basename(f, '.ozf') } +
      %w[Applications System OS Module Property Resolve]

    code_without_comments = code.lines.reject { |line| line =~ /^\s*%/ }.join

    # Try to get modules needed
    imports = code_without_comments.scan(/(?:\{|=\s*|\{\w+\s)([A-Z][A-Za-z]+)\.[a-z]\w*/).map(&:first).uniq

    # Remove builtin modules (some of them might be explicitely loaded with Module.link for extras)
    imports -= %w[Array List Tuple Record Dictionary Char String Atom]

    (imports-all_modules).each { |unknown| errors << "Unknown module: #{unknown}\n" unless ignore.include? unknown }

    imports &= all_modules
    imports |= %w[Application System]

    # Remove graphical dependencies
    code.gsub! /\{(Browse|Show) /, '{System.show '

    # define already "declare"
    code.gsub! /\bdeclare\b/, ''

    # do not exit if we have a browser
    code << "\n{Application.exit 0}" unless imports.include? 'Browser' or code_without_comments.include? 'thread'

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
  functor = "#{executable}.functor.oz"
  File.open(functor, "w+") { |fh| fh.write code }

  IO.popen(["ozc", "-x", "-o#{executable}", functor, :err => [:child, :out]]) do |io|
    begin
      compilation = io.read
    ensure
      File.unlink functor unless options.include? :keep
    end
  end

  executable = nil if !compilation.empty? and !compilation.include?('-------------------- accepted')

  return errors+compilation, executable
end
