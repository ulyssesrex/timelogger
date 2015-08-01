require 'rails_helper'

describe SessionsHelper do
  let(:user) { create(:user, :with_remembering) }  
  
  describe "#log_in" do
    
    it "stores the user's id in the sessions hash" do
      helper.log_in(user)
      expect(session[:user_id]).to eq(user.id)
    end
  end
  
  describe "#remember" do    
    
    it "remembers the user" do
      expect { 
        helper.remember(user) 
      }.to change(user, :remember_digest)
    end
    
    it "creates an encrypted user_id cookie" do
      cookies[:user_id] = nil
      helper.remember(user)
      expect(cookies[:user_id]).not_to be_nil
    end
    
    it "creates a remember_token cookie" do
      helper.remember(user)
      expect(cookies[:remember_token]).to eq(user.remember_token)
    end
  end
  
  describe "#current_user" do
    
    context "user_id is stored in session hash" do
      before(:example) { helper.log_in(user) }
      it { expect(helper.current_user).to eq(user) }
    end
    
    context "user_id is stored in cookies" do
      before(:example) { helper.remember(user) }
      it { expect(helper.current_user).to eq(user) }
    end
    
    context "user_id is not stored" do
      it { expect(assigns(:current_user)).to be nil }
    end
  end
  
  describe "#current_user?" do
    
    before(:each) { helper.remember(user) }
  
    context "user is current user" do        
      it { expect(helper.current_user?(user)).to be true }
    end
    
    context "user is not current user" do
      let(:other_user) { create(:user, :with_remembering) }
      it { expect(helper.current_user?(other_user)).to be false }
    end
  end

  describe "#logged_in?" do
    
    context "user is not logged in" do
      it { expect(helper.logged_in?).to be false }
    end
    
    context "user is logged in" do
      before(:example) { helper.log_in(user) }
      it { expect(helper.logged_in?).to be true }
    end
  end
  
  describe "#forget" do
    
    before(:each) do
      helper.remember(user) 
      helper.forget(user)
    end
    
    it "forgets the user" do
      expect(user.remember_digest).to be_nil
    end
    
    it "deletes the user_id cookie" do
      expect(cookies[:user_id]).to be_nil
    end
    
    it "deletes the remember_token cookie" do
      expect(cookies[:remember_token]).to be_nil
    end
  end
  
  describe "#log_out" do
    
    before(:each) do
      helper.remember(user)
      helper.log_out
    end
    
    it "calls forget(user)" do
      expect(cookies[:remember_token]).to be_nil
    end
    
    it "deletes user_id from session hash" do
      expect(session[:user_id]).to be_nil
    end
    
    it "sets @current_user to nil" do
      expect(assigns(:current_user)).to be_nil
    end
  end
  
  describe "#redirect_back_or" do
    # Tested in sessions_controller_spec.rb.    
  end
  
  describe "#store_location" do
    # Tested in users_controller_spec.rb.
  end
end