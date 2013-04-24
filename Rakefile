def generate(from_ext, to_ext, &block)
  Dir["*#{from_ext}"].each do |from|
    to = File.basename(from, from_ext) + to_ext
    file to => [from] do
      case block.arity
      when 1
        block.call from
      when 2
        block.call from, to
      else
        raise 'Block should take 1 or 2 arguments'
      end
    end
  end
end

generate '.coffee', '.js' do |from, to|
  sh "coffee -c #{from}"
end

generate '.svg', '.png' do |from, to|
  sh "/usr/bin/inkscape --without-gui --export-png=#{to} --export-area-page #{from}"
end

generate '.scss', '.css' do |from, to|
  sh "compass compile --quiet --sass-dir . --css-dir . #{from}"
end

generate '.wav', '.wav.base64' do |from, to|
  sh "base64 < #{from} > #{to}"
end

generate '.wav', '.mp3' do |from, to|
  sh "lame #{from} #{to}"
end

generate '.wav', '.ogg' do |from, to|
  sh "oggenc #{from} -o #{to}"
end

task :default => Rake::Task::tasks
