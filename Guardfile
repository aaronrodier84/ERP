folders_to_monitor =  %w(actions controllers helpers jobs models presenters services)

guard :minitest, all_on_start: false do
  watch(%r{^test/(.*)\/?test_(.*)\.rb$})
  watch(%r{^test/.+_test\.rb$})

  folders_to_monitor.each do |folder|
    watch(%r(^app/#{folder}/(.*)\.rb)) { |m| "test/#{folder}/#{m[1]}_test.rb"}
  end
  watch(%r{^lib/(.+)\.rb}) { |m| "test/lib/#{m[1]}_test.rb" }
end

guard 'ctags-bundler', src_path: ["app", "lib", "test/support" ],
                       binary: 'ripper-tags',
                       arguments: '-R  --exclude=vendor' do
  watch(/^(app|lib|test\/support)\/.*\.rb$/)
  watch('Gemfile.lock')
end
