require 'spec_helper'
require 'httparty'

describe "api", :api do
    it "tests an api" do
        response = HTTParty.get('https://www.google.com')
        expect(response).to be_success
    end
    describe 'nest this one' do
        it 'testsa another api' do
            "yay"
        end
    end
end