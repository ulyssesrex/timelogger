require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user)  { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:organization) { create(:organization) }
  
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end
  
  describe "#account_activation" do
    let(:mail) { UserMailer.account_activation(user) }
    
    before(:each) do |spec|
      mail unless spec.metadata[:skip_before]
    end   
    
    it "assigns @user" do
      expect(mail.body.encoded).to match(user.last_name)
    end
    
    it "renders the subject" do
      expect(mail.subject).to eq("Activate your Timelogger account")
    end
    
    it "renders the receiver email" do
      expect(mail.to).to eq([user.email])
    end
    
    it "renders the sender email" do
      expect(mail.from).to eq(['from@example.com'])
    end
  end

  describe "#organization_activation" do
    let(:mail) { UserMailer.organization_activation(organization, admin) }
    
    before(:each) do |spec|
      mail unless spec.metadata[:skip_before]
    end 
    
    it "assigns @admin" do
      expect(mail.body.encoded).to match(admin.last_name)
    end
    
    it "assigns @organization" do
      expect(mail.body.encoded).to match(organization.name)
    end
    
    it "renders the subject" do
      expect(mail.subject).to eq("Activate Organization's Timelogger account")
    end
    
    it "renders the receiver email" do
      expect(mail.to).to eq([admin.email])
    end
    
    it "renders the sender email" do
      expect(mail.from).to eq(['from@example.com'])
    end
  end
  
  describe "#password_reset" do
    let(:mail) { UserMailer.password_reset(user) }
    
    before(:each) do |spec|
      mail unless spec.metadata[:skip_before]
    end 

    it "assigns @user" do
      expect(mail.body.encoded).to match(user.first_name)
    end
    
    it "renders the subject" do
      expect(mail.subject).to eq("Reset your Timelogger password")
    end
    
    it "renders the receiver email" do
      expect(mail.to).to eq([user.email])
    end
    
    it "renders the sender email" do
      expect(mail.from).to eq(['from@example.com'])
    end
  end

end
