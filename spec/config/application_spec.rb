require 'rails_helper'

RSpec.describe Partnr::Application, 'configuration' do
  describe "#version" do
    it "returns a string" do
      expect(subject.version().class).to eq(String)
    end

    it "is v1.3.0" do
      expect(subject.version).to eq("1.3.0")
    end
  end
end
