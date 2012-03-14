task :roflscale => :environment do
  app = Rails.application
  app.reload_routes!
  asts = app.routes.set.map { |r| r.ast }

  ragel = Journey::Ragel.new app.class.name, asts
  source = ragel.source

  gem = Journey::Ragel::Gem.new 'roflscale', app.class.name, source
  FileUtils.rm_rf 'tmp/roflscale'
  FileUtils.mkdir 'tmp/roflscale'
  Dir.chdir 'tmp/roflscale' do
    gem.write_all
    sh 'rake package'
    sh 'mv *.gem ../../'
  end
end
