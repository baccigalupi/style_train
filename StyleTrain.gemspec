# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{StyleTrain}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kane Baccigalupi"]
  s.date = %q{2010-03-23}
  s.description = %q{StyleTrain helps CSS with Ruby color classes}
  s.email = %q{baccigalupi@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LISENCE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/style_train.rb",
     "lib/style_train/color.rb",
     "lib/style_train/color_types/color_type.rb",
     "lib/style_train/color_types/hex_color.rb",
     "lib/style_train/color_types/hsl_color.rb",
     "lib/style_train/color_types/keyword_color.rb",
     "lib/style_train/color_types/rgb_color.rb",
     "lib/style_train/support/gnash.rb",
     "lib/style_train/support/string.rb",
     "spec/color_spec.rb",
     "spec/color_type_spec.rb",
     "spec/hex_color_spec.rb",
     "spec/keyword_color_spec.rb",
     "spec/rgb_color_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "utils/alexch_color_gist/color.rb",
     "utils/alexch_color_gist/color_test.rb",
     "utils/overview.txt"
  ]
  s.homepage = %q{http://github.com/baccigalupi/style_train}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{StyleTrain helps CSS with Ruby color classes}
  s.test_files = [
    "spec/color_spec.rb",
     "spec/color_type_spec.rb",
     "spec/hex_color_spec.rb",
     "spec/keyword_color_spec.rb",
     "spec/rgb_color_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

