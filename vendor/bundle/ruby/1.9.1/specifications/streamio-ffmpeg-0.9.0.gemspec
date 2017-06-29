# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "streamio-ffmpeg"
  s.version = "0.9.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Backeus"]
  s.date = "2012-07-24"
  s.description = "Simple yet powerful wrapper around ffmpeg to get metadata from movies and do transcoding."
  s.email = ["david@streamio.se"]
  s.homepage = "http://github.com/streamio/streamio-ffmpeg"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23.2"
  s.summary = "Reads metadata and transcodes movies."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.7"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.7"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.7"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
  end
end
