# app/models/contact.rb (Model)

def name
  [firstname, lastname].join " "
end

def self.by_letter(letter)
  where("lastname LIKE ?", "#{letter}%").order(:lastname)
end

# spec/models/contact_spec.rb (Model spec)

require 'rails_helper'

describe Contact do 
  
  # validation examples -->
  
  it 'has a valid factory' do
    Factory.create(:contact).should be_valid
  end
  
  it 'is invalid without a firstname' do
    Factory.build(:contact, firstname: nil).should_not be_valid
  end
  
  it 'is invalid without a lastname' do
    Factory.build(:contact, lastname: nil).should_not be_valid
  end
  
  it "returns a contact's full name as a string" do
    contact = Factory(:contact, firstname: "John", lastname: "Doe")
    contact.name.should == "John Doe"
  end
  
  describe "filter last name by letter" do
    before :each do
      @smith   = Factory(:contact, lastname: "Smith")
      @jones   = Factory(:contact, lastname: "Jones")
      @johnson = Factory(:contact, lastname: "Johnson")
    end
    
    context "matching letters" do
      it "returns a sorted array of results that match" do
        Contact.by_letter("J").should == [johnson, jones]
      end
    end
    
    context "non-matching letters" do
      it "doesn't return contacts that don't start with the provided letter" do
        Contact.by_letter("J").should_not include smith
      end
    end    
  end
end

# spec/factories/contacts.rb (Factories for contact model)-- btw create a factories subdir

require 'faker'

FactoryGirl.define do
  factory :contact do |f|
    f.firstname { Faker::Name.first_name }
    f.lastname  { Faker::Name.last_name }
  end
  factory :invalid_contact, parent: :contact do |f|
    f.firstname nil
  end
end

# spec/models/phone_spec.rb (Model spec)

###
it "does not allow duplicate phone numbers per contact" do
  contact = Factory(:contact)
  Factory(:phone, contact: contact, phone_type: "home", number: "785-555-1234")
  Factory.build(:phone, contact: contact, phone_type: "mobile", number: "785-555-1234").should_not be_valid
end

# app/models/phone.rb (Model)

validates :phone, uniqueness: { scope: :contact_id }

# app/controllers/contacts_controller.rb (Controller)

# ... other code omitted

def new
  @contact = Contact.new
  %w(home office mobile).each do |phone|
    @contact.phones.build(phone_type: phone)
  end
end

# spec/controllers/contacts_controller_spec.rb (Controller spec)
require 'rails_helper'

describe ContactsController do
  
  describe 'GET #index' do
    
    it "populates an array of contacts" do
      contact = Factory(:contact)
      get :index
      assigns(:contacts).should eq([contact])
    end    
    
    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end
  
  describe 'GET #show' do
    
    it "assigns the requested contact to @contact" do
      contact = Factory(:contact)
      get :show, id: contact
      assigns(:contact).should eq(contact)
    end
    
    it "renders the :show view" do
      get :show, id: Factory(:contact)
      response.should render_template :show
    end
  end

  describe 'GET #new' do
    
    it "assigns a home, office, and mobile phone to the new contact" do
      get :new
      assigns(:contact).phones.map { |p| p.phone_type }.should eq %w(home office mobile)
    end
    
    it 'assigns a new Contact to @contact' do
      ###
    end
    
    it "renders the :new template" do
      ###
    end    
  end
  
  describe 'POST #create' do
    
    context 'with valid attributes' do
      
      it "creates a new contact" do
        expect{
          post :create, contact: Factory.attributes_for(:contact)
        }.to change(Contact, :count).by(1)
      end
      
      it "redirects to the new contact" do
        post :create, contact: Factory.attributes_for(:contact)
        response.should redirect_to Contact.last
      end
    end
    
    context "with invalid attributes" do
      
      it "does not save the new contact" do
        expect{
          post :create, contact: Factory.attributes_for(:invalid_contact)
        }.to_not change(Contact, :count)
      end
      
      it "re-renders the new method" do
        post :create, contact: Factory.attributes_for(:invalid_contact)
        response.should render_template :new
      end      
    end    
  end
  
  describe 'PUT update' do
    
    before :each do
      @contact = Factory(:contact, firstname: "Lawrence", lastname: "Smith")
    end
        
    context "valid attributes" do
      
      it "locates the requested @contact" do
        put :update, id: @contact, contact: Factory.attributes_for(:contact)
        assigns(:contact).should eq(@contact)
      end
      
      it "changes @contact's attributes" do
        put :update, id: @contact, contact: Factory.attributes_for(:contact, firstname: "Larry", lastname: "Smith")
        @contact.reload
        @contact.firstname.should eq("Larry")
        @contact.lastname.should eq("Smith")
      end
      
      it "redirects to the updated contact" do
        put :update, id: @contact, contact: Factory.attributes_for(:contact)
        response.should redirect_to @contact
      end
    end
    
    context "invalid attributes" do
      
      it "locates the requested @contact" do
        put :update, id: @contact, contact: Factory.attributes_for(:invalid_contact)
        assigns(:contact).should eq(@contact)
      end
      
      it "does not change @contact's attributes" do
        put :update, id: @contact, contact: Factory.attributes_for(:contact, firstname: "Larry", lastname: nil)
        @contact.reload
        @contact.firstname.should_not eq("Larry")
        @contact.lastname.should eq("Smith")
      end
      
      it "re-renders the edit method" do
        put :update, id: @contact, contact: Factory.attributes_for(:invalid_contact)
        response.should render_template :edit
      end      
    end
  end
  
  describe 'DELETE destroy' do    
    before :each do
      @contact = Factory(:contact)
    end
    
    it "deletes the contact" do
      expect{
        delete :destroy, id: @contact
      }.to change(Contact, :count).by(-1)
    end
    
    it "redirects to contacts#index" do
      delete :destroy, id: @contact
      response.should redirect_to contacts_url
    end
  end  
end

# spec/requests/contacts_spec.rb (Requests spec)

require 'rails_helper'

describe "Contacts" do  
  describe "Manage contacts" do
    
    it "Adds a new contact and displays the results" do
      visit contacts_url
      expect{
        click_link 'New Contact'
        fill_in 'Firstname', with: "John"
        fill_in 'Lastname',  with: "Smith"
        fill_in 'home',      with: "555-1234"
        fill_in 'office',    with: "555-3324"
        fill_in 'mobile',    with: "555-7888"
        click_button "Create Contact"
      }.to_change(Contact, :count).by(1)
      page.should have_content "Contact was successfully created."
      within 'h1' do
        page.should have_content "John Smith"
      end
      page.should have_content "home 555-1234"
      page.should have_content "office 555-3324"
      page.should have_content "mobile 555-7888"
    end
    
    it "Deletes a contact" do
      contact = Factory(:contact, firstname: "Aaron", lastname: "Sumner")
      visit contacts_path
      expect{
        within "#contact_#{contact.id}" do
          click_link 'Destroy'
        end
      }.to change(Contact, :count).by(-1)
      page.should have_content "Listing contacts"
      page.should_not have_content "Aaron Sumner"
    end
    
    it "Deletes a contact", js: true do
      # this is a gem needed for capybara's Selenium driver.
      DatabaseCleaner.clean      
      contact = Factory(:contact, firstname: "Aaron", lastname: "Sumner")
      visit contacts_path
      expect{
        within "#contact_#{contact.id}" do
          click_link 'Destroy'
        end
        alert = page.driver.browser.switch_to.alert
        alert.accept
      }.to change(Contact, :count).by(-1)
      page.should have_content "Listing contacts"
      page.should_not have_content "Aaron Sumner"
    end
  end
end
