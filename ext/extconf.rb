require 'mkmf'
require 'tmpdir'
require 'ostruct'
require_relative '../lib/wkhtmltopdf_installer'

def probe
  @probe ||= case RUBY_PLATFORM
               when /x86_64-darwin.*/
                 OpenStruct.new(script: 'macos', platform: 'osx-cocoa-x86-64', ext: 'pkg')
               when /x86_64-linux/
                 OpenStruct.new(script: 'linux', platform: 'linux-precise-amd64', ext: 'deb')
               when /i[3456]86-linux/
                 OpenStruct.new(script: 'linux', platform: 'linux-precise-i386', ext: 'deb')
               else
                 raise NotImplementedError "Unsupported ruby platform #{RUBY_PLATFORM}"
             end
end

def version
  WkhtmltopdfInstaller::VERSION
end

def makefile_dir
  File.dirname(__FILE__)
end

# Some examples:
# "http://downloads.sourceforge.net/project/wkhtmltopdf/#{version}/wkhtmltox-#{version}_osx-cocoa-x86-64.pkg"
# "http://downloads.sourceforge.net/project/wkhtmltopdf/#{version}/wkhtmltox-#{version}_linux-precise-amd64.deb"
# "http://downloads.sourceforge.net/project/wkhtmltopdf/#{version}/wkhtmltox-#{version}_linux-precise-i386.deb"
def package_url
  "http://downloads.sourceforge.net/project/wkhtmltopdf/#{version}/wkhtmltox-#{version}_#{probe.platform}.#{probe.ext}"
end

# The main Makefile contains settings only. The actual work is done by os-specific Makefile.xxxxx files
File.write "#{makefile_dir}/Makefile", <<-EOF
URL = #{package_url}
LIBEXEC = #{WkhtmltopdfInstaller.libexec_dir}
TARGET = #{WkhtmltopdfInstaller.wkhtmltopdf_path}
TMPDIR = #{Dir.mktmpdir}
all: unpack
install: copy clean
include Makefile.#{probe.script}
include Makefile.common
EOF

