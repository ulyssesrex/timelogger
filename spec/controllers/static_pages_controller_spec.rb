require 'rails_helper'

describe StaticPagesController do
  let(:user) { create(:user) }
  
  describe "filters" do
    describe "#logged_in" do
      context "user is not logged in" do
        before(:example) { get :about }
        it { expect(flash[:danger]).to be_present }
        
        before(:example) { get :help }
        it { expect(flash[:danger]).to be_present }
      end
      
      context "user is logged in" do
        before(:each) { log_in user }
        
        before(:example) { get :about }
        it { expect(flash[:danger]).not_to be_present }
        
        before(:example) { get :help }
        it { expect(flash[:danger]).not_to be_present }
      end
    end
  end
  
  describe "actions" do
    before(:each) do |spec|
      log_in user unless spec.metadata[:skip_login]
    end
    
    describe "GET #home", :skip_login do
      it "renders the :home template" do
        get :home
        expect(response).to render_template :home
      end  
    end

    describe "GET #about" do
      it "renders the :about template" do
        get :about
        expect(response).to render_template :about
      end
    end

    describe "GET #help" do
      it "renders the :help template" do
        get :help
        expect(response).to render_template :help
      end
    end
  end
end