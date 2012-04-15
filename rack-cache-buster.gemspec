# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rack-cache-buster"
  s.version = "0.2.2"

  s.authors = ["Tom Lea"]
  s.date = "2011-03-07"
  s.email = "commit@tomlea.co.uk"
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown"]
  s.homepage = "http://tomlea.co.uk/"
  s.rdoc_options = ["--main", "README.markdown"]
  s.require_paths = ["recipes", "lib"]
  s.rubyforge_project = "rack-cache-buster"
  s.rubygems_version = "1.8.15"
  s.summary = "Place this in your rack stack and all caching will be gone."

  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'rack-test'
end
