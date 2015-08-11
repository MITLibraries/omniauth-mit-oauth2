require 'spec_helper'

describe OmniAuth::Strategies::MITOAuth2 do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {})}
  let(:raw_info_hash) { {'name' => 'Foo', 'email' => 'foo@example.com'} }
  subject do
    OmniAuth::Strategies::MITOAuth2.new('appid', 'secret', @options || {}).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  describe 'client options' do
    it 'has correct name' do
      expect(subject.options.name).to eq('mit_oauth2')
    end

    it 'has correct site' do
      expect(subject.client.site).to eq('https://oidc.mit.edu')
    end

    it 'has correct authorize url' do
      expect(subject.client.options[:authorize_url]).to eq('/authorize')
    end

    it 'has correct token url' do
      expect(subject.client.options[:token_url]).to eq('/token')
    end
  end

  describe 'info' do
    before do
      allow(subject).to receive(:raw_info) { raw_info_hash }
    end

    it 'has name' do
      expect(subject.info[:name]).to eq('Foo')
    end

    it 'has email' do
      expect(subject.info[:email]).to eq('foo@example.com')
    end
  end

  describe 'extra' do
    before do
      allow(subject).to receive(:raw_info) { raw_info_hash }
    end

    it 'includes raw_info' do
      expect(subject.extra[:raw_info]).to eq(raw_info_hash)
    end
  end
end
