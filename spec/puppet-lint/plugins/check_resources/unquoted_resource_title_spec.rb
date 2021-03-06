require 'spec_helper'

describe 'unquoted_resource_title' do
  describe 'quoted resource title on single line resource' do
    let(:code) { "file { 'foo': }" }

    its(:problems) { should be_empty }
  end

  describe 'unquoted resource title on single line resource' do
    let(:code) { "file { foo: }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => "unquoted resource title",
        :linenumber => 1,
        :column     => 8,
      })
    }
  end

  describe 'unquoted resource title on single line resource w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "file { foo: }" }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => "unquoted resource title",
        :linenumber => 1,
        :column     => 8,
      })
    }

    its(:manifest) { should == "file { 'foo': }" }
  end

  describe 'quoted resource title on multi line resource' do
    let(:code) { "
      file { 'foo':
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'unquoted resource title on multi line resource' do
    let(:code) { "
      file { foo:
      }"
    }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => "unquoted resource title",
        :linenumber => 2,
        :column     => 14,
      })
    }
  end

  describe 'unquoted resource title on multi line resource w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "
      file { foo:
      }"
    }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => "unquoted resource title",
        :linenumber => 2,
        :column     => 14,
      })
    }

    its(:manifest) { should == "
      file { 'foo':
      }"
    }
  end

  describe 'condensed resources with quoted titles' do
    let(:code) { "
      file {
        'foo': ;
        'bar': ;
      }"
    }

    its(:problems) { should be_empty }
  end

  describe 'condensed resources with an unquoted title' do
    let(:code) { "
      file {
        'foo': ;
        bar: ;
      }"
    }

    its(:problems) {
      should only_have_problem({
        :kind       => :warning,
        :message    => "unquoted resource title",
        :linenumber => 4,
        :column     => 9,
      })
    }
  end

  describe 'condensed resources with an unquoted title w/fix' do
    before do
      PuppetLint.configuration.fix = true
    end

    after do
      PuppetLint.configuration.fix = false
    end

    let(:code) { "
      file {
        'foo': ;
        bar: ;
      }"
    }

    its(:problems) {
      should only_have_problem({
        :kind       => :fixed,
        :message    => "unquoted resource title",
        :linenumber => 4,
        :column     => 9,
      })
    }

    its(:manifest) { should == "
      file {
        'foo': ;
        'bar': ;
      }"
    }
  end

  describe 'single line resource with an array of titles (all quoted)' do
    let(:code) { "file { ['foo', 'bar']: }" }

    its(:problems) { should be_empty }
  end

  describe 'resource inside a case statement' do
    let(:code) { "
      case $ensure {
        'absent': {
          file { \"some_file_${name}\":
            ensure => absent,
          }
        }
      }"
    }

    its(:problems) { should == [] }
  end

  describe 'issue #116' do
    let(:code) { "
      $config_file_init = $::operatingsystem ? {
        /(?i:Debian|Ubuntu|Mint)/ => '/etc/default/foo',
        default                   => '/etc/sysconfig/foo',
      }"
    }

    its(:problems) { should == [] }
  end

  describe 'case statement' do
    let(:code) { %{
      case $operatingsystem {
        centos: {
          $version = '1.2.3'
        }
        solaris: {
          $version = '3.2.1'
        }
        default: {
          fail("Module ${module_name} is not supported on ${operatingsystem}")
        }
      }}
    }

    its(:problems) { should == [] }
  end
end
