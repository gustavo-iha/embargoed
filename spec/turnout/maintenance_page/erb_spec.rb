require 'spec_helper'

describe Embargoed::MaintenancePage::Erb do
  describe 'class methods' do

    its(:media_types) { should eql %w{text/html application/xhtml+xml} }
    its(:extension) { should eql 'html.erb' }
  end

  describe 'instance methods' do
    let(:reason) { nil }
    let(:instance) { Embargoed::MaintenancePage::Erb.new(*[reason].compact) }
    subject { instance }

    describe '#reason' do
      context 'without a reason' do
        its(:reason) { should eql '' }
      end

      context 'with a reason' do
        let(:reason) { "Just because.\nOkay!" }

        its(:reason) { should eql "<p>Just because.</p>\n<p>Okay!</p>" }
      end
    end

    describe '#rack_response' do
      let(:reason) { 'Oops!' }
      let(:code) { nil }
      let(:retry_after) { nil }
      let(:raw_response) { instance.rack_response(code, retry_after) }
      subject { Rack::MockResponse.new(*raw_response) }

      context 'without a code' do
        it { expect(raw_response).to be_an Array }
        its(:status) { should eql 503 }
        its(:headers) { should be_a Hash }
        its(:headers) { should have_key 'Content-Type' }
        its(:headers) { should have_key 'Content-Length' }
        its(:headers) { should_not have_key 'Retry-After' }
        its(:content_type) { should eql 'text/html' }
        its(:content_length) { should eql 1199 }
        it { expect(raw_response[2]).to be_an Array }
        its(:body) { should match '<html>' }
        its(:body) { should match 'Oops!' }
      end

      context 'with a code' do
        let(:code) { 418 }
        its(:status) { should eql 418 }
      end

      context 'with retry_after' do
        let(:retry_after) { 3600 }
        its(:headers) { should include('Retry-After' => '3600')}
      end
    end
  end
end
