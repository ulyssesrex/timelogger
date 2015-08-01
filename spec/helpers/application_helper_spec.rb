require 'rails_helper'

describe ApplicationHelper do
  let(:user) { create(:user) }
  
  describe "#full_name" do
    context "last name listed first" do
      it { 
        expect(
        helper.full_name(user, last_first=true)
        ).to eq("#{user.last_name}, #{user.first_name}")
      }
    end
    
    context "first name listed first" do
      it {
        expect(helper.full_name(user, last_first=false)
        ).to eq("#{user.first_name} #{user.last_name}")
      }
    end
  end
end