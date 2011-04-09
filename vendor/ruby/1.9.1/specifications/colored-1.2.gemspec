# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{colored}
  s.version = "1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Wanstrath"]
  s.date = %q{2010-02-10}
  s.description = %q{  >> puts "this is red".red
 
  >> puts "this is red with a blue background (read: ugly)".red_on_blue

  >> puts "this is red with an underline".red.underline

  >> puts "this is really bold and really blue".bold.blue

  >> logger.debug "hey this is broken!".red_on_yellow     # in rails

  >> puts Color.red "This is red" # but this part is mostly untested
}
  s.email = %q{chris@ozmm.org}
  s.files = ["README", "Rakefile", "LICENSE", "lib/colored.rb", "test/colored_test.rb"]
  s.homepage = %q{http://github.com/defunkt/colored}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.2}
  s.summary = %q{Add some color to your life.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
