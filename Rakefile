require 'config/requirements'

Dir['tasks/**/*.rake'].each { |rake| load rake }

desc "Rebuilds the rdoc pages"
task :rdoc do
  `rdoc README.rdoc  lib/* lib/commission_junction/* -o doc`
end
