# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "capistrano-unicorn"
  s.version = "0.1.10"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Sosedoff"]
  s.date = "2013-07-25"
  s.description = "Capistrano plugin that integrates Unicorn server tasks."
  s.email = "dan.sosedoff@gmail.com"
  s.homepage = "https://github.com/sosedoff/capistrano-unicorn"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Unicorn integration for Capistrano"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<capistrano>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<capistrano>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<capistrano>, [">= 0"])
  end
end
