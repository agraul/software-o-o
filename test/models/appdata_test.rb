# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class AppdataTest < ActiveSupport::TestCase
  test 'Factory Appdata can be parsed' do
    VCR.use_cassette('default') do
      appdata = Appdata.get('factory')
      pkg_list = appdata[:apps].map { |p| p[:pkgname] }.uniq

      assert_equal 689, pkg_list.size
      %w[0ad 4pane opera steam].each do |pkg|
        assert_includes pkg_list, pkg
      end
    end
  end

  test 'Missing appdata should not raise anything' do
    VCR.use_cassette('default') do
      stub_request(:get, %r{https://download.opensuse.org/tumbleweed/repo/oss/repodata/(.*)-appdata.xml.gz})
        .to_return(status: 404, body: '', headers: {})
      appdata = Appdata.get('factory')
      # Should still include non-oss appdata
      assert_not_empty appdata[:apps]
      assert_includes appdata[:apps].map { |e| e[:name] }, 'Opera'
    end
  end

  test 'Leap 15.1 Appdata can be parsed' do
    VCR.use_cassette('default') do
      appdata = Appdata.get('leap15.1')
      pkg_list = appdata[:apps].map { |p| p[:pkgname] }.uniq

      assert_equal 631, pkg_list.size
      ['0ad', '4pane', 'steam'].each do |pkg|
        assert_includes pkg_list, pkg
      end
    end
  end
end
