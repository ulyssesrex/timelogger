require 'rails_helper'

describe Supervision do 
  let(:supervision) { create(:supervision) }
  
  it 'has a valid factory' do
    expect(supervision).to be_valid
  end
  
  describe 'validations' do
    it 'rejects objects without a supervisor' do
      expect(build(:supervision, supervisor_id: nil)).not_to be_valid
    end
    
    it 'rejects objects without a supervisee' do
      expect(build(:supervision, supervisee_id: nil)).not_to be_valid
    end
  end
end