# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "carrierwave-video"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["rheaton"]
  s.date = "2012-08-02"
  s.description = "Transcodes to html5-friendly videos."
  s.email = ["rachelmheaton@gmail.com"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.requirements = ["ruby, version 1.9 or greater", "ffmpeg, version 0.11.1 or greater with libx256, libfaac, libtheora, libvorbid, libvpx enabled"]
  s.rubyforge_project = "carrierwave-video"
  s.rubygems_version = "1.8.23.2"
  s.summary = "Carrierwave extension that uses ffmpeg to transcode videos."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<streamio-ffmpeg>, [">= 0"])
      s.add_runtime_dependency(%q<carrierwave>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 2.10.0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<streamio-ffmpeg>, [">= 0"])
      s.add_dependency(%q<carrierwave>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 2.10.0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<streamio-ffmpeg>, [">= 0"])
    s.add_dependency(%q<carrierwave>, [">= 0"])
  end
end
