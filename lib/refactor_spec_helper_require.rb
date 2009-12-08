#refactor spec_helper require statement

#spec_helper is required through different ways, File.expand_path / File.join() / É which results in it being loaded several times!
require 'rake'

files = FileList["spec/**/*_spec.rb"].reject{|file|File.directory?(file)}
files.each do |file|
  lines = File.readlines(file)
  lines = lines.map do |line|
    if line =~ /require.*spec_helper/
      "require 'spec/spec_helper'\n"
    else
      line
    end
  end
  File.open(file,'w'){|f| f.write lines.join('') }
end