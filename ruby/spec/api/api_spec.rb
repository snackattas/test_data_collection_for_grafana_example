require 'spec_helper'
require 'httparty'

describe "api", :api do
    it "tests an api" do
        response = HTTParty.get('https://www.google.com')
        expect(response).to be_success
    end

    it "a pending test" do
        pending("i am a pending message")
        1/0
    end

    describe 'this one' do
        it 'tests another api' do
            "yay"
        end
    end
end